<script setup lang="ts">
import RetroLayout from '@/layouts/retro/RetroLayout.vue';
import Brainstorming from '@/pages/retro/components/Brainstorming.vue';
import Discussion from '@/pages/retro/components/Discussion.vue';
import RegisterModal from '@/pages/retro/components/RegisterModal.vue';
import Summary from '@/pages/retro/components/Summary.vue';
import Theming from '@/pages/retro/components/Theming.vue';
import Voting from '@/pages/retro/components/Voting.vue';
import Waiting from '@/pages/retro/components/Waiting.vue';
import { Feedback, Participant, Retro } from '@/types/model';
import { router, usePage } from '@inertiajs/vue3';
import { useEchoPublic } from '@laravel/echo-vue';
import { computed, ref, watch } from 'vue';

const props = defineProps<{
    retro: Retro;
    showRegisterModal: boolean;
    participants: Participant[];
    positiveFeedbackOfParticipant: Feedback[];
    negativeFeedbackOfParticipant: Feedback[];
    positiveFeedbackOfRetro: Feedback[];
    negativeFeedbackOfRetro: Feedback[];
    positiveFeedbackGroups: any[];
    negativeFeedbackGroups: any[];
    participantVotes?: any[];
    actions?: any[];
}>();

console.log('xxx show retro state:', props.retro.state, 'full retro:', props.retro);

const page = usePage();
const participant = computed(() => page.props.participant as Participant | undefined);

// Create a local copy of participants that we can mutate
const localParticipants = ref<Participant[]>([...props.participants]);

const selectedParticipantId = ref<string | null>(null);

// Local status for optimistic UI update - Initialize from global participant
const localStatus = ref<'active' | 'finished'>(participant.value?.status || 'active');

useEchoPublic(`retro.${props.retro.id}`, 'ParticipantJoined', (e: any) => {
    console.log('ParticipantJoined event received:', e);
    // Check if participant already exists to prevent duplicates
    const existingParticipant = localParticipants.value.find((p) => p.session_id === e.participant.session_id);
    if (!existingParticipant) {
        localParticipants.value.push(e.participant);
        console.log('New participant added:', e.participant.name);
    } else {
        console.log('Participant already exists, skipping:', e.participant.name);
    }
});

useEchoPublic(`retro.${props.retro.id}`, 'ParticipantSelected', (e: any) => {
    console.log('participant selected event');
    selectedParticipantId.value = e.participantId;
});

useEchoPublic(`retro.${props.retro.id}`, 'PhaseCompleted', (e: any) => {
    console.log('phase completed event');
    router.get(route('retro.show', props.retro.id), {}, { only: ['retro'] });
});

useEchoPublic(`retro.${props.retro.id}`, 'ActionCreated', (e: any) => {
    console.log('action created event');
    router.get(route('retro.show', props.retro.id), {}, { only: ['actions'], preserveScroll: true });
});

// Handle group-related events
const handleGroupEvent = (e: any) => {
    console.log('Group event received:', e);
    // Reload the retro data to get updated groups and feedback
    router.get(
        route('retro.show', props.retro.id),
        {},
        {
            only: ['positiveFeedbackGroups', 'negativeFeedbackGroups', 'positiveFeedbackOfRetro', 'negativeFeedbackOfRetro'],
            preserveScroll: true,
        },
    );
};

// Listen for group creation and deletion events
useEchoPublic(`retro.${props.retro.id}`, 'GroupCreated', handleGroupEvent);
useEchoPublic(`retro.${props.retro.id}`, 'GroupDeleted', handleGroupEvent);

// Listen for participant status changes
useEchoPublic(`retro.${props.retro.id}`, 'ParticipantStatusChanged', (e: any) => {
    console.log('Participant status changed:', e);
    // Update the local participant status
    const participantIndex = localParticipants.value.findIndex((p) => p.session_id === e.participant.session_id);
    if (participantIndex !== -1) {
        localParticipants.value[participantIndex] = {
            ...localParticipants.value[participantIndex],
            status: e.participant.status,
        };
    } else {
        // If participant not in list, add them
        localParticipants.value.push(e.participant);
    }

    // Update local status if it's the current participant
    if (participant.value?.session_id === e.participant.session_id) {
        localStatus.value = e.participant.status;
    }
});

// Initialize local status from participant data
const initializeLocalStatus = () => {
    if (participant.value?.session_id) {
        const currentParticipant = localParticipants.value.find((p) => p.session_id === participant.value?.session_id);
        localStatus.value = currentParticipant?.status || participant.value.status || 'active';
    }
};

// Initialize on mount
initializeLocalStatus();

// Update local status when participant changes
watch(
    () => participant.value,
    () => {
        initializeLocalStatus();
    },
    { immediate: true },
);

const currentParticipantStatus = computed(() => localStatus.value);

function completePhase() {
    router.patch(route('retro.phase.complete', props.retro.id));
}

function toggleStatus() {
    // Optimistic update
    localStatus.value = localStatus.value === 'finished' ? 'active' : 'finished';

    // Also update in localParticipants for consistency
    if (participant.value?.session_id) {
        const participantIndex = localParticipants.value.findIndex((p) => p.session_id === participant.value?.session_id);
        if (participantIndex !== -1) {
            localParticipants.value[participantIndex] = {
                ...localParticipants.value[participantIndex],
                status: localStatus.value,
            };
        }
    }

    // Send to server
    router.post(route('retro.participant.toggle-status', props.retro.id));
}

const positiveFeedbackOfRetroWithHighlights = computed(() => {
    return props.positiveFeedbackOfRetro.map((feedback) => ({
        ...feedback,
        isHighlighted: feedback.participant?.session_id === selectedParticipantId.value,
    }));
});

// Das gleiche für negatives Feedback
const negativeFeedbackOfRetroWithHighlights = computed(() => {
    return props.negativeFeedbackOfRetro.map((feedback) => ({
        ...feedback,
        isHighlighted: feedback.participant?.session_id === selectedParticipantId.value,
    }));
});
</script>

<template>
    <RetroLayout :retroId="retro.id" :participants="localParticipants" :participant="participant" :currentPhase="retro.state">
        <RegisterModal :retroId="retro.id" v-if="showRegisterModal" />
        <Waiting v-if="retro.state === 'WAITING'" :participant="participant" :participants="localParticipants" @startRetro="completePhase()" />
        <Brainstorming
            v-else-if="retro.state === 'BRAINSTORMING'"
            :positiveFeedback="positiveFeedbackOfParticipant"
            :negativeFeedback="negativeFeedbackOfParticipant"
            :currentStatus="currentParticipantStatus"
            :participant="participant"
            @completeBrainstorming="completePhase()"
            @toggleStatus="toggleStatus()"
        />
        <Theming
            v-else-if="retro.state === 'THEMING'"
            :positiveFeedback="positiveFeedbackOfRetroWithHighlights"
            :negativeFeedback="negativeFeedbackOfRetroWithHighlights"
            :positiveFeedbackGroups="positiveFeedbackGroups"
            :negativeFeedbackGroups="negativeFeedbackGroups"
            :currentStatus="currentParticipantStatus"
            :participant="participant"
            @completeBrainstorming="completePhase()"
            @toggleStatus="toggleStatus()"
        />
        <Voting
            v-else-if="retro.state === 'VOTING'"
            :positiveFeedback="positiveFeedbackOfRetroWithHighlights"
            :negativeFeedback="negativeFeedbackOfRetroWithHighlights"
            :positiveFeedbackGroups="positiveFeedbackGroups"
            :negativeFeedbackGroups="negativeFeedbackGroups"
            :participantVotes="participantVotes || []"
            :currentStatus="currentParticipantStatus"
            :participant="participant"
            @completeVoting="completePhase()"
            @toggleStatus="toggleStatus()"
        />
        <Discussion
            v-else-if="retro.state === 'DISCUSSION'"
            :positiveFeedback="positiveFeedbackOfRetroWithHighlights"
            :negativeFeedback="negativeFeedbackOfRetroWithHighlights"
            :positiveFeedbackGroups="positiveFeedbackGroups"
            :negativeFeedbackGroups="negativeFeedbackGroups"
            :actions="actions || []"
            :retroId="retro.id"
            :currentStatus="currentParticipantStatus"
            :participant="participant"
            @completeDiscussion="completePhase()"
            @toggleStatus="toggleStatus()"
        />
        <Summary v-else-if="retro.state === 'SUMMARY'" :actions="actions || []" :participants="localParticipants" :participant="participant" :retro="retro" />
    </RetroLayout>
</template>

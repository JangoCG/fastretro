<template>
    <div>
        <PhaseHeader
            title="Voting Phase"
            :description="`Each participant has ${maxVotes} votes. Your remaining votes: ${remainingVotes}`"
            :currentStatus="currentStatus"
            :participant="participant"
            primaryButtonText="Finish Voting"
            @primaryAction="$emit('completeVoting')"
            @toggleStatus="$emit('toggleStatus')"
        />

        <div class="flex w-full justify-center gap-4">
            <VotingColumn
                mode="positive"
                :feedback="positiveFeedback"
                :feedback-groups="positiveFeedbackGroups"
                :participant-votes="participantVotes"
                :remaining-votes="remainingVotes"
                @vote="handleVote"
                @unvote="handleUnvote"
            />
            <VotingColumn
                mode="negative"
                :feedback="negativeFeedback"
                :feedback-groups="negativeFeedbackGroups"
                :participant-votes="participantVotes"
                :remaining-votes="remainingVotes"
                @vote="handleVote"
                @unvote="handleUnvote"
            />
        </div>
    </div>
</template>

<script setup lang="ts">
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight';
import PhaseHeader from '@/pages/retro/components/PhaseHeader.vue';
import { type FeedbackGroup } from '@/types/feedback-group';
import { type Participant } from '@/types/model';
import { router } from '@inertiajs/vue3';
import { computed } from 'vue';
import VotingColumn from './VotingColumn.vue';

/**
 * Props for the Voting component
 */
interface Props {
    /** Positive feedback items with highlight capability */
    positiveFeedback: FeedbackWithHighlight[];
    /** Negative feedback items with highlight capability */
    negativeFeedback: FeedbackWithHighlight[];
    /** Positive feedback groups */
    positiveFeedbackGroups: FeedbackGroup[];
    /** Negative feedback groups */
    negativeFeedbackGroups: FeedbackGroup[];
    /** Current participant's votes */
    participantVotes: any[];
    /** Current participant's status */
    currentStatus: 'active' | 'finished';
    /** Maximum votes per participant */
    maxVotes?: number;
    /** Current participant */
    participant?: Participant;
}

/**
 * Events emitted by the Voting component
 */
interface Emits {
    /** Emitted when voting phase should be completed */
    completeVoting: [];
    /** Emitted when participant toggles their status */
    toggleStatus: [];
}

const props = withDefaults(defineProps<Props>(), {
    maxVotes: 3,
});

const emit = defineEmits<Emits>();

/**
 * Calculate remaining votes for the current participant
 */
const remainingVotes = computed(() => {
    return props.maxVotes - props.participantVotes.length;
});

/**
 * Handle voting for a feedback item or group
 * @param payload Vote payload containing type and id
 */
function handleVote(payload: { type: 'feedback' | 'group'; id: number }): void {
    if (remainingVotes.value <= 0) {
        return;
    }

    router.post(route('votes.store'), payload, {
        preserveScroll: true,
        onError: (errors) => {
            console.error('Error voting:', errors);
        },
    });
}

/**
 * Handle removing a vote from a feedback item or group
 * @param payload Unvote payload containing type and id
 */
function handleUnvote(payload: { type: 'feedback' | 'group'; id: number }): void {
    // Find the vote to delete based on the payload
    const voteToDelete = props.participantVotes.find((vote) => {
        if (payload.type === 'feedback') {
            return vote.feedback_id === payload.id;
        } else {
            return vote.feedback_group_id === payload.id;
        }
    });

    if (!voteToDelete) {
        console.error('Vote not found to delete');
        return;
    }

    router.delete(route('votes.destroy', voteToDelete.id), {
        preserveScroll: true,
        onError: (errors) => {
            console.error('Error removing vote:', errors);
        },
    });
}
</script>

<style scoped>
/* Add any voting-specific styles here */
</style>

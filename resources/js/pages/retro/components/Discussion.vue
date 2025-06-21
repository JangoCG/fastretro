<template>
    <div>
        <PhaseHeader
            title="Discussion Phase"
            description="Items are sorted by vote count. Focus on the highest-voted topics first."
            :currentStatus="currentStatus"
            :participant="participant"
            primaryButtonText="Finish Discussion"
            @primaryAction="$emit('completeDiscussion')"
            @toggleStatus="$emit('toggleStatus')"
        />

        <div class="flex w-full justify-center gap-4">
            <DiscussionColumn mode="positive" :feedback="positiveFeedback" :feedback-groups="positiveFeedbackGroups" />
            <DiscussionColumn mode="negative" :feedback="negativeFeedback" :feedback-groups="negativeFeedbackGroups" />
            <ActionsColumn :actions="actions" :retro-id="retroId" />
        </div>
    </div>
</template>

<script setup lang="ts">
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight';
import { type FeedbackGroup } from '@/types/feedback-group';
import { type Participant } from '@/types/model';
import PhaseHeader from '@/pages/retro/components/PhaseHeader.vue';
import DiscussionColumn from './DiscussionColumn.vue';
import ActionsColumn from './ActionsColumn.vue';

/**
 * Props for the Discussion component
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
    /** Actions for this retro */
    actions: any[];
    /** Retro ID */
    retroId: string;
    /** Current participant's status */
    currentStatus: 'active' | 'finished';
    /** Current participant */
    participant?: Participant;
}

/**
 * Events emitted by the Discussion component
 */
interface Emits {
    /** Emitted when discussion phase should be completed */
    completeDiscussion: [];
    /** Emitted when participant toggles their status */
    toggleStatus: [];
}

defineProps<Props>();
defineEmits<Emits>();
</script>

<style scoped>
/* Add any discussion-specific styles here */
</style>

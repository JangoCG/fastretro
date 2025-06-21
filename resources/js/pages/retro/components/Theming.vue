<script setup lang="ts">
import Column from '@/pages/retro/components/Column.vue';
import PhaseHeader from '@/pages/retro/components/PhaseHeader.vue';
import { FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight';
import { Participant } from '@/types/model';
import { router } from '@inertiajs/vue3';

defineProps<{
    positiveFeedback: FeedbackWithHighlight[];
    negativeFeedback: FeedbackWithHighlight[];
    positiveFeedbackGroups: any[];
    negativeFeedbackGroups: any[];
    currentStatus: 'active' | 'finished';
    participant?: Participant;
}>();
defineEmits(['completeBrainstorming', 'toggleStatus']);

const handleUngroup = (groupId: number) => {
    router.delete(route('tasks.ungroup', { group: groupId }));
};

const handleVote = (groupId: number) => {
    router.post(route('tasks.vote', { group: groupId }));
};

const handleTaskOrderUpdate = (taskId: number, columnId: number, order: number, groupId: number | null = null) => {
    router.put(route('tasks.reorder'), {
        task_id: taskId,
        column_id: columnId,
        order,
        group_id: groupId,
    });
};

// Handle group creation
const handleCreateGroup = (columnId: number, taskIds: number[]) => {
    router.post(route('tasks.group'), {
        column_id: columnId,
        task_ids: taskIds,
    });
};
</script>

<template>
    <PhaseHeader
        title="Theming Phase"
        description="Group related topics by using drag and drop"
        :currentStatus="currentStatus"
        :participant="participant"
        primaryButtonText="Finish Grouping"
        @primaryAction="$emit('completeBrainstorming')"
        @toggleStatus="$emit('toggleStatus')"
    />
    <div class="flex w-full justify-center gap-4">
        <Column
            :mode="'positive'"
            :feedback="positiveFeedback"
            :feedbackGroups="positiveFeedbackGroups"
            phase="THEMING"
            @update-task-order="(taskId, order, groupId) => handleTaskOrderUpdate(taskId, column.id, order, groupId)"
            @create-group="(taskIds) => handleCreateGroup(column.id, taskIds)"
            @create-group-with="(targetTaskId, droppedTaskIds) => handleCreateGroupWith(column.id, targetTaskId, droppedTaskIds)"
            @ungroup="handleUngroup"
            @vote="handleVote"
        />
        <Column :mode="'negative'" :feedback="negativeFeedback" :feedbackGroups="negativeFeedbackGroups" phase="THEMING" />
    </div>
</template>

<style scoped></style>

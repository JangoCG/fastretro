<template>
    <div class="w-full rounded-lg bg-white p-4 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
        <!-- Column Header -->
        <h1 class="mb-4 text-xl font-bold text-black">{{ title }}</h1>

        <!-- Feedback Form -->
        <form @submit.prevent="submitFeedback" class="mb-4">
            <div class="grid w-full gap-2">
                <Textarea v-model="form.content" placeholder="Type your message here." class="border-2 border-black focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400" />
                <Button class="bg-yellow-400 text-black border-2 border-black hover:bg-yellow-300 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all">Add item</Button>
            </div>
            <InputError :message="form.errors.content" />
        </form>

        <!-- Remove Zone -->
        <RemoveZone
            :is-visible="isDraggingGroupedItem && isGroupingAllowed"
            :is-active="dragOverRemoveZone"
            :message="removeZoneMessage"
            @drag-over="handleDragOver"
            @drag-enter="handleRemoveZoneDragEnter"
            @drag-leave="handleRemoveZoneDragLeave"
            @drop="handleRemoveZoneDrop"
        />

        <!-- Feedback Items -->
        <div class="space-y-2">
            <!-- Feedback Groups (only during THEMING phase) -->
            <FeedbackGroup
                v-if="feedbackGroups && isGroupingAllowed"
                v-for="group in feedbackGroups"
                :key="`group-${group.id}`"
                :group="group"
                :mode="mode"
                :is-drop-target="dragOverGroupId === group.id"
                :is-draggable="isGroupingAllowed"
                :dragged-item-id="draggedItemId"
                @drag-over="handleDragOver"
                @drag-enter="handleGroupDragEnter"
                @drag-leave="handleGroupDragLeave"
                @drop="handleGroupDrop"
                @item-drag-start="handleDragStart"
                @item-drag-end="handleDragEnd"
            />

            <!-- Individual Feedback Items (not in groups) -->
            <div
                v-for="item of ungroupedFeedback"
                :key="`wrapper-${item.id}`"
                class="rounded-lg p-1 transition-all duration-150"
                @drop="handleDrop($event, item)"
                @dragover="handleDragOver"
                @dragenter="handleDragEnter($event, item)"
                @dragleave="handleDragLeave($event)"
                :class="{
                    'is-drop-target': isGroupingAllowed && dragOverTargetId === item.id && draggedItemId !== item.id,
                }"
            >
                <FeedbackItem
                    :item="item"
                    :mode="mode"
                    :is-dragged="draggedItemId === item.id"
                    :is-draggable="isGroupingAllowed"
                    :show-grip="isGroupingAllowed"
                    @drag-start="handleDragStart"
                    @drag-end="handleDragEnd"
                />
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import InputError from '@/components/InputError.vue';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { useFeedbackDragDrop } from '@/composables/useFeedbackDragDrop';
import { FeedbackType } from '@/pages/retro/components/feedback-type.enum';
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight';
import { store } from '@/routes/feedback';
import { type FeedbackGroup as FeedbackGroupType } from '@/types/feedback-group';
import { type Feedback } from '@/types/model';
import { useForm } from '@inertiajs/vue3';
import { computed, toRef } from 'vue';
import FeedbackGroup from './FeedbackGroup.vue';
import FeedbackItem from './FeedbackItem.vue';
import RemoveZone from './RemoveZone.vue';

/**
 * Props for the Column component
 */
interface Props {
    /** Column mode determining the type of feedback */
    mode: 'positive' | 'negative';
    /** Array of feedback items to display */
    feedback: Feedback[] | FeedbackWithHighlight[];
    /** Array of feedback groups (optional, only shown during THEMING phase) */
    feedbackGroups?: FeedbackGroupType[];
    /** Current phase of the retro process */
    phase?: string;
}

const props = defineProps<Props>();

/**
 * Form for submitting new feedback
 */
const form = useForm({
    content: '',
    kind: props.mode === 'positive' ? FeedbackType.POSITIVE : FeedbackType.NEGATIVE,
});

/**
 * Column title based on mode
 */
const title = computed(() => (props.mode === 'positive' ? '✨ What went well?' : '💭 What could be better?'));

/**
 * Initialize drag and drop functionality
 */
const {
    // State
    draggedItemId,
    dragOverTargetId,
    dragOverGroupId,
    dragOverRemoveZone,
    isDraggingGroupedItem,

    // Handlers
    handleDragStart,
    handleDragEnd,
    handleDragOver,
    handleDrop,
    handleDragEnter,
    handleDragLeave,
    handleGroupDragEnter,
    handleGroupDragLeave,
    handleGroupDrop,
    handleRemoveZoneDragEnter,
    handleRemoveZoneDragLeave,
    handleRemoveZoneDrop,

    // Utils
    isItemInAnyGroup,
    ungroupedFeedback,

    // Computed
    isGroupingAllowed,
} = useFeedbackDragDrop({
    feedback: toRef(props, 'feedback'),
    feedbackGroups: toRef(props, 'feedbackGroups'),
    phase: toRef(props, 'phase'),
});

/**
 * Message to display in the remove zone
 */
const removeZoneMessage = computed(() => {
    return 'Drop here to remove from group';
});

/**
 * Submit new feedback item
 */
function submitFeedback(): void {
    form.submit(store(), {
        onSuccess: () => {
            form.reset('content');
        },
    });
}
</script>

<style scoped>
@reference "tailwindcss";

/* Drop target styling for individual items */
.is-drop-target {
    @apply border-2 border-yellow-400 bg-yellow-100 shadow-lg ring-2 ring-yellow-400;
}
</style>

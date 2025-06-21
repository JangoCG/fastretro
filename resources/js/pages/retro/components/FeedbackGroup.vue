<template>
    <div
        class="feedback-group rounded-lg border-2 border-dashed p-3 shadow-sm transition-all duration-200"
        :class="[
            groupClasses,
            {
                'is-group-drop-target': isDropTarget,
            },
            isDropTarget ? dropTargetClasses : '',
        ]"
        @dragover="handleDragOver"
        @dragenter="handleDragEnter"
        @dragleave="handleDragLeave"
        @drop="handleDrop"
    >
        <!-- Group Header -->
        <div class="mb-2 flex items-center justify-between">
            <div class="flex items-center gap-2">
                <!--                <div class="h-2 w-2 rounded-full" :class="headerClasses.dot"></div>-->
                <!--                <span class="text-sm font-semibold" :class="headerClasses.text"> Grouped Items ({{ group.feedbacks.length }}) </span>-->
            </div>
            <slot name="actions" :group="group">
                <!-- Default slot for actions like ungroup button -->
            </slot>
        </div>

        <!-- Feedback Items in Group -->
        <div class="space-y-3">
            <FeedbackItem
                v-for="item in group.feedbacks"
                :key="`group-item-${item.id}`"
                :item="item"
                :mode="mode"
                :is-dragged="draggedItemId === item.id"
                :is-draggable="isDraggable"
                :show-grip="isDraggable"
                :is-in-group="true"
                :grip-size="12"
                :card-classes="itemBackgroundClass"
                text-size="text-sm"
                content-padding="px-3 py-2"
                @drag-start="handleItemDragStart"
                @drag-end="handleItemDragEnd"
            />
        </div>
    </div>
</template>

<script setup lang="ts">
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight';
import { type FeedbackGroup } from '@/types/feedback-group';
import { type Feedback } from '@/types/model';
import { computed } from 'vue';
import FeedbackItem from './FeedbackItem.vue';

/**
 * Props for the FeedbackGroup component
 */
interface Props {
    /** The feedback group to display */
    group: FeedbackGroup;
    /** Column mode determining the type of feedback */
    mode?: 'positive' | 'negative';
    /** Whether the group is currently a drop target */
    isDropTarget?: boolean;
    /** Whether items in the group can be dragged */
    isDraggable?: boolean;
    /** ID of the currently dragged item */
    draggedItemId?: number | null;
}

/**
 * Events emitted by the FeedbackGroup component
 */
interface Emits {
    /** Emitted when drag over occurs on the group */
    dragOver: [event: DragEvent];
    /** Emitted when drag enters the group */
    dragEnter: [event: DragEvent, group: FeedbackGroup];
    /** Emitted when drag leaves the group */
    dragLeave: [event: DragEvent];
    /** Emitted when drop occurs on the group */
    drop: [event: DragEvent, group: FeedbackGroup];
    /** Emitted when an item in the group starts being dragged */
    itemDragStart: [event: DragEvent, item: Feedback | FeedbackWithHighlight];
    /** Emitted when an item in the group stops being dragged */
    itemDragEnd: [event: DragEvent];
}

const props = withDefaults(defineProps<Props>(), {
    isDropTarget: false,
    isDraggable: true,
    draggedItemId: null,
});

const emit = defineEmits<Emits>();

/**
 * Group styling classes based on mode
 */
const groupClasses = computed(() => {
    if (props.mode === 'positive') {
        return 'border-green-300 bg-gradient-to-r from-green-50 to-emerald-50';
    } else if (props.mode === 'negative') {
        return 'border-red-300 bg-gradient-to-r from-red-50 to-rose-50';
    }
    return 'border-purple-300 bg-gradient-to-r from-purple-50 to-indigo-50';
});

/**
 * Group header styling based on mode
 */
const headerClasses = computed(() => {
    if (props.mode === 'positive') {
        return { dot: 'bg-green-500', text: 'text-green-700' };
    } else if (props.mode === 'negative') {
        return { dot: 'bg-red-500', text: 'text-red-700' };
    }
    return { dot: 'bg-purple-500', text: 'text-purple-700' };
});

/**
 * Drop target styling based on mode
 */
const dropTargetClasses = computed(() => {
    if (props.mode === 'positive') {
        return 'border-green-500 bg-gradient-to-r from-green-100 to-emerald-100 ring-green-400';
    } else if (props.mode === 'negative') {
        return 'border-red-500 bg-gradient-to-r from-red-100 to-rose-100 ring-red-400';
    }
    return 'border-purple-500 bg-gradient-to-r from-purple-100 to-indigo-100 ring-purple-400';
});

/**
 * Background class based on feedback type for items in group
 */
const itemBackgroundClass = computed(() => {
    if (props.mode === 'positive') {
        return 'border border-green-200 bg-green-50 hover:border-green-300';
    } else if (props.mode === 'negative') {
        return 'border border-red-200 bg-red-50 hover:border-red-300';
    }
    return 'border border-purple-200 bg-white hover:border-purple-300';
});

/**
 * Handle drag over event on the group
 */
function handleDragOver(event: DragEvent): void {
    emit('dragOver', event);
}

/**
 * Handle drag enter event on the group
 */
function handleDragEnter(event: DragEvent): void {
    emit('dragEnter', event, props.group);
}

/**
 * Handle drag leave event on the group
 */
function handleDragLeave(event: DragEvent): void {
    emit('dragLeave', event);
}

/**
 * Handle drop event on the group
 */
function handleDrop(event: DragEvent): void {
    emit('drop', event, props.group);
}

/**
 * Handle drag start event for items within the group
 */
function handleItemDragStart(event: DragEvent, item: Feedback | FeedbackWithHighlight): void {
    emit('itemDragStart', event, item);
}

/**
 * Handle drag end event for items within the group
 */
function handleItemDragEnd(event: DragEvent): void {
    emit('itemDragEnd', event);
}
</script>

<style scoped>
@reference "tailwindcss";

/* Group drop target styling - dynamic classes applied via computed property */
.is-group-drop-target {
    @apply shadow-lg ring-2;
    transform: scale(1.02);
}

/* Group container styling */
.feedback-group {
    position: relative;
}
</style>

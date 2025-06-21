import { Ref } from 'vue';
import { Feedback } from '@/types/model';
import { FeedbackGroup } from '@/types/feedback-group';

/**
 * Drag and drop state for feedback items
 */
export interface DragState {
    /** ID of the currently dragged item */
    draggedItemId: Ref<number | null>;
    /** ID of the target item being hovered over for individual drops */
    dragOverTargetId: Ref<number | null>;
    /** ID of the group being hovered over for group drops */
    dragOverGroupId: Ref<number | null>;
    /** Whether the remove zone is being hovered over */
    dragOverRemoveZone: Ref<boolean>;
    /** Whether the currently dragged item is part of a group */
    isDraggingGroupedItem: Ref<boolean>;
}

/**
 * Configuration for the feedback drag and drop functionality
 */
export interface FeedbackDragDropConfig {
    /** Array of feedback items */
    feedback: Ref<Feedback[]>;
    /** Array of feedback groups (optional) */
    feedbackGroups: Ref<FeedbackGroup[] | undefined>;
    /** Current phase of the retro process */
    phase: Ref<string | undefined>;
}

/**
 * Drag and drop event handlers for feedback items and groups
 */
export interface DragHandlers {
    /** Handle drag start event for feedback items */
    handleDragStart: (event: DragEvent, draggedItem: Feedback) => void;
    /** Handle drag end event */
    handleDragEnd: (event: DragEvent) => void;
    /** Handle drag over event */
    handleDragOver: (event: DragEvent) => void;
    /** Handle drop on individual feedback item */
    handleDrop: (event: DragEvent, targetItem: Feedback) => void;
    /** Handle drag enter on individual feedback item */
    handleDragEnter: (event: DragEvent, targetItem: Feedback) => void;
    /** Handle drag leave on individual feedback item */
    handleDragLeave: (event: DragEvent) => void;
    /** Handle drag enter on feedback group */
    handleGroupDragEnter: (event: DragEvent, group: FeedbackGroup) => void;
    /** Handle drag leave on feedback group */
    handleGroupDragLeave: (event: DragEvent) => void;
    /** Handle drop on feedback group */
    handleGroupDrop: (event: DragEvent, group: FeedbackGroup) => void;
    /** Handle drag enter on remove zone */
    handleRemoveZoneDragEnter: (event: DragEvent) => void;
    /** Handle drag leave on remove zone */
    handleRemoveZoneDragLeave: (event: DragEvent) => void;
    /** Handle drop on remove zone */
    handleRemoveZoneDrop: (event: DragEvent) => void;
}

/**
 * Utility functions for feedback group operations
 */
export interface GroupUtils {
    /** Check if an item is in a specific group */
    isItemInGroup: (itemId: number, group: FeedbackGroup) => boolean;
    /** Check if an item is in any group */
    isItemInAnyGroup: (itemId: number) => boolean;
    /** Get feedback items that are not in any group */
    ungroupedFeedback: Ref<Feedback[]>;
    /** Set of all grouped feedback IDs for performance */
    groupedFeedbackIds: Ref<Set<number>>;
}

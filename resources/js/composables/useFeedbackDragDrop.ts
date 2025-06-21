import { type FeedbackGroup } from '@/types/feedback-group';
import { type Feedback } from '@/types/model';
import { DragHandlers, DragState, FeedbackDragDropConfig, GroupUtils } from '@/types/use-feedback-drag-drop-types';
import { router } from '@inertiajs/vue3';
import { computed, ref, watch } from 'vue';

/**
 * Composable for managing drag and drop functionality for feedback items and groups.
 *
 * This composable provides:
 * - Drag state management
 * - Event handlers for drag and drop operations
 * - Group management utilities
 * - Phase-based restrictions (only allows grouping during THEMING phase)
 *
 * @param config Configuration object containing feedback data and phase information
 * @returns Object containing drag state, handlers, utilities, and computed properties
 */
export function useFeedbackDragDrop(config: FeedbackDragDropConfig) {
    const { feedback, feedbackGroups, phase } = config;

    // --- REACTIVE STATE ---

    const draggedItemId = ref<number | null>(null);
    const dragOverTargetId = ref<number | null>(null);
    const dragOverGroupId = ref<number | null>(null);
    const dragOverRemoveZone = ref<boolean>(false);
    const isDraggingGroupedItem = ref<boolean>(false);

    // --- COMPUTED PROPERTIES ---

    /**
     * Whether grouping is allowed in the current phase
     * Only allow grouping during THEMING phase
     */
    const isGroupingAllowed = computed(() => phase.value === 'THEMING');

    /**
     * Set of all grouped feedback IDs for efficient lookups
     */
    const groupedFeedbackIds = computed(() => {
        const ids = new Set<number>();
        if (feedbackGroups.value) {
            feedbackGroups.value.forEach((group) => {
                group.feedbacks.forEach((feedback) => {
                    ids.add(feedback.id);
                });
            });
        }
        return ids;
    });

    /**
     * Feedback items that are not in any group
     */
    const ungroupedFeedback = computed(() => {
        return feedback.value.filter((item) => !groupedFeedbackIds.value.has(item.id));
    });

    // --- UTILITY FUNCTIONS ---

    /**
     * Reset all drag-related state to initial values
     */
    function resetDragState(): void {
        draggedItemId.value = null;
        dragOverTargetId.value = null;
        dragOverGroupId.value = null;
        dragOverRemoveZone.value = false;
        isDraggingGroupedItem.value = false;
    }

    /**
     * Check if an item is in a specific group
     * @param itemId The ID of the feedback item
     * @param group The group object to check
     * @returns True if the item is in the group
     */
    function isItemInGroup(itemId: number, group: FeedbackGroup): boolean {
        return group.feedbacks.some((feedback) => feedback.id === itemId);
    }

    /**
     * Check if an item is in any group
     * @param itemId The ID of the feedback item
     * @returns True if the item is in any group
     */
    function isItemInAnyGroup(itemId: number): boolean {
        return groupedFeedbackIds.value.has(itemId);
    }

    // --- DRAG HANDLERS ---

    /**
     * Handle the start of a drag operation
     * Sets up the data transfer and initializes drag state
     */
    function handleDragStart(event: DragEvent, draggedItem: Feedback): void {
        if (!event.dataTransfer) {
            console.error('No dataTransfer available in drag start event!');
            return;
        }

        // Set data transfer
        event.dataTransfer.effectAllowed = 'move';
        event.dataTransfer.setData('text/plain', draggedItem.id.toString());

        // Use setTimeout to ensure the drag state is set after the drag operation starts
        // This prevents browser interference with the drag operation
        setTimeout(() => {
            draggedItemId.value = draggedItem.id;
            isDraggingGroupedItem.value = isItemInAnyGroup(draggedItem.id);
        }, 0);
    }

    /**
     * Handle the end of a drag operation
     * Cleans up the drag state
     */
    function handleDragEnd(event: DragEvent): void {
        resetDragState();
    }

    /**
     * Handle drag over events
     * Required to allow dropping
     */
    function handleDragOver(event: DragEvent): void {
        event.preventDefault(); // Essential to allow dropping
        if (event.dataTransfer) {
            event.dataTransfer.dropEffect = 'move'; // Show proper cursor
        }
    }

    /**
     * Handle dropping an item on another individual item
     * Creates a new group or moves item between groups
     */
    function handleDrop(event: DragEvent, targetItem: Feedback): void {
        event.preventDefault();
        event.stopPropagation();

        // Only allow grouping during THEMING phase
        if (!isGroupingAllowed.value) {
            resetDragState();
            return;
        }

        // Do not allow drops on items that are in groups
        if (isItemInAnyGroup(targetItem.id)) {
            resetDragState();
            return;
        }

        if (!event.dataTransfer) {
            resetDragState();
            return;
        }

        const draggedId = parseInt(event.dataTransfer.getData('text/plain'), 10);
        const targetId = targetItem.id;

        if (draggedId === targetId) {
            resetDragState();
            return;
        }

        // Check if dragged item is already in a group
        if (isItemInAnyGroup(draggedId)) {
            // If dragged item is in a group, remove it first, then create new group
            router.post(
                route('feedback.groups.remove'),
                { feedbackId: draggedId },
                {
                    preserveScroll: true,
                    onSuccess: () => {
                        // After removing from group, create new group with target
                        router.post(
                            route('feedback.groups.create'),
                            { draggedId, targetId },
                            {
                                preserveScroll: true,
                                onSuccess: () => resetDragState(),
                                onError: () => resetDragState(),
                            },
                        );
                    },
                    onError: () => resetDragState(),
                },
            );
        } else {
            // If dragged item is not in a group, create new group directly
            router.post(
                route('feedback.groups.create'),
                { draggedId, targetId },
                {
                    preserveScroll: true,
                    onSuccess: () => resetDragState(),
                    onError: () => resetDragState(),
                },
            );
        }
    }

    /**
     * Handle drag enter on individual items
     * Highlights the target item for potential grouping
     */
    function handleDragEnter(event: DragEvent, targetItem: Feedback): void {
        event.preventDefault();

        // Only allow grouping during THEMING phase
        if (!isGroupingAllowed.value) {
            return;
        }

        // Do not highlight if dragging over itself
        if (draggedItemId.value === targetItem.id) {
            return;
        }

        // Do not allow individual drops if target item is in a group
        if (isItemInAnyGroup(targetItem.id)) {
            return;
        }

        // Allow drops from both grouped and ungrouped items
        dragOverGroupId.value = null;
        dragOverTargetId.value = targetItem.id;
    }

    /**
     * Handle drag leave on individual items
     * Removes highlighting when no longer hovering
     */
    function handleDragLeave(event: DragEvent): void {
        // Check if we are still inside the wrapper's children, prevents flickering
        const target = event.relatedTarget as Node;
        const currentTarget = event.currentTarget as Node;
        if (target && currentTarget.contains(target)) {
            return;
        }
        dragOverTargetId.value = null;
    }

    /**
     * Handle drag enter on feedback groups
     * Highlights the group for potential item addition
     */
    function handleGroupDragEnter(event: DragEvent, group: FeedbackGroup): void {
        event.preventDefault();

        // Don't handle if we're dragging an item from within this group
        const draggedId = draggedItemId.value;
        if (draggedId && isItemInGroup(draggedId, group)) {
            return;
        }

        // Only allow grouping during THEMING phase
        if (!isGroupingAllowed.value) {
            return;
        }

        // Highlight group if we are dragging an item that's not already in this group
        if (draggedId && !isItemInGroup(draggedId, group)) {
            dragOverGroupId.value = group.id;
        }
    }

    /**
     * Handle drag leave on feedback groups
     * Removes group highlighting when no longer hovering
     */
    function handleGroupDragLeave(event: DragEvent): void {
        const target = event.relatedTarget as Node;
        const currentTarget = event.currentTarget as Node;
        if (target && currentTarget.contains(target)) {
            return;
        }
        dragOverGroupId.value = null;
    }

    /**
     * Handle dropping an item on a feedback group
     * Adds the item to the group
     */
    function handleGroupDrop(event: DragEvent, group: FeedbackGroup): void {
        event.preventDefault();
        event.stopPropagation();

        if (!event.dataTransfer) {
            resetDragState();
            return;
        }

        const draggedId = parseInt(event.dataTransfer.getData('text/plain'), 10);

        // Don't handle if we're dragging an item from within this group
        if (isItemInGroup(draggedId, group)) {
            resetDragState();
            return;
        }

        // Only allow grouping during THEMING phase
        if (!isGroupingAllowed.value) {
            resetDragState();
            return;
        }

        // Add the dragged feedback to this group (works for both ungrouped items and items from other groups)
        router.post(
            route('feedback.groups.add'),
            { feedbackId: draggedId, groupId: group.id },
            {
                preserveScroll: true,
                onSuccess: () => resetDragState(),
                onError: () => resetDragState(),
            },
        );
    }

    /**
     * Handle drag enter on the remove zone
     * Activates the remove zone visual feedback
     */
    function handleRemoveZoneDragEnter(event: DragEvent): void {
        event.preventDefault();

        // Only allow during THEMING phase
        if (!isGroupingAllowed.value) {
            return;
        }

        // Show remove zone only for grouped items
        if (draggedItemId.value !== null && isDraggingGroupedItem.value) {
            dragOverRemoveZone.value = true;
        }
    }

    /**
     * Handle drag leave on the remove zone
     * Deactivates the remove zone visual feedback
     */
    function handleRemoveZoneDragLeave(event: DragEvent): void {
        const target = event.relatedTarget as Node;
        const currentTarget = event.currentTarget as Node;
        if (target && currentTarget.contains(target)) {
            return;
        }
        dragOverRemoveZone.value = false;
    }

    /**
     * Handle dropping an item on the remove zone
     * Removes the item from its group
     */
    function handleRemoveZoneDrop(event: DragEvent): void {
        event.preventDefault();
        event.stopPropagation();

        // Only allow during THEMING phase
        if (!isGroupingAllowed.value) {
            resetDragState();
            return;
        }

        // Only handle drops from grouped items
        if (!isDraggingGroupedItem.value) {
            resetDragState();
            return;
        }

        if (event.dataTransfer && draggedItemId.value !== null) {
            const draggedId = parseInt(event.dataTransfer.getData('text/plain'), 10);

            // Remove the item from its group
            router.post(
                route('feedback.groups.remove'),
                { feedbackId: draggedId },
                {
                    preserveScroll: true,
                    onSuccess: () => resetDragState(),
                    onError: () => resetDragState(),
                },
            );
        } else {
            resetDragState();
        }
    }

    // --- WATCHERS ---

    /**
     * Watch for changes in feedback groups and reset drag state
     * This prevents stale state when groups are modified externally
     */
    watch(
        () => feedbackGroups.value,
        () => {
            resetDragState();
        },
        { deep: true },
    );

    // --- RETURN INTERFACE ---

    const dragState: DragState = {
        draggedItemId,
        dragOverTargetId,
        dragOverGroupId,
        dragOverRemoveZone,
        isDraggingGroupedItem,
    };

    const handlers: DragHandlers = {
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
    };

    const utils: GroupUtils = {
        isItemInGroup,
        isItemInAnyGroup,
        ungroupedFeedback,
        groupedFeedbackIds,
    };

    return {
        // State
        ...dragState,

        // Handlers
        ...handlers,

        // Utils
        ...utils,

        // Computed
        isGroupingAllowed,

        // Functions
        resetDragState,
    };
}

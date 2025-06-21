# Retro Feedback Components

This directory contains the Vue components and composables for the feedback system in the retrospective application.

## Architecture Overview

The feedback system is built with a clean separation of concerns using Vue 3 Composition API, following modern Vue.js best practices.

### Components

#### `Column.vue`
The main container component for a feedback column (positive/negative). Manages the form for adding new feedback and orchestrates the display of feedback items and groups.

**Props:**
- `mode`: 'positive' | 'negative' - determines the column type
- `feedback`: Array of feedback items to display
- `feedbackGroups`: Array of feedback groups (optional, only shown during THEMING phase)
- `phase`: Current retro phase (controls grouping functionality)

#### `FeedbackItem.vue`
Reusable component for individual feedback items. Handles drag interactions and visual states.

**Props:**
- `item`: The feedback item data
- `isDragged`: Whether the item is currently being dragged
- `isDraggable`: Whether the item can be dragged
- `showGrip`: Whether to show the drag handle
- `isInGroup`: Whether the item is part of a group (affects styling)

#### `FeedbackGroup.vue`
Component for displaying and managing feedback groups. Handles group-level drag and drop interactions.

**Props:**
- `group`: The feedback group data
- `isDropTarget`: Whether the group is currently a drop target
- `isDraggable`: Whether items in the group can be dragged
- `draggedItemId`: ID of the currently dragged item

#### `RemoveZone.vue`
Component for the drag and drop removal zone. Provides visual feedback and handles removal operations.

**Props:**
- `isVisible`: Whether the remove zone should be shown
- `isActive`: Whether the zone is currently being hovered over
- `message`: Text to display in the removal zone

### Composables

#### `useFeedbackDragDrop.ts`
Core composable that manages all drag and drop functionality for feedback items and groups.

**Features:**
- Complete drag and drop state management
- Event handlers for all drag operations
- Group management utilities
- Phase-based restrictions (only allows grouping during THEMING phase)
- TypeScript support with comprehensive interfaces

**State Management:**
- `draggedItemId`: ID of currently dragged item
- `dragOverTargetId`: ID of target item for individual drops
- `dragOverGroupId`: ID of target group for group drops
- `dragOverRemoveZone`: Whether remove zone is active
- `isDraggingGroupedItem`: Whether dragged item is in a group

**Key Functions:**
- `handleDragStart`: Initializes drag operation
- `handleDrop`: Handles drops on individual items (creates new groups)
- `handleGroupDrop`: Handles drops on groups (adds items to groups)
- `handleRemoveZoneDrop`: Handles removal from groups
- `isItemInAnyGroup`: Utility to check group membership
- `ungroupedFeedback`: Computed property for items not in groups

### Types

#### `feedback-group.ts`
TypeScript definitions for feedback group structures and utilities.

**Interfaces:**
- `FeedbackGroup`: Complete group structure with metadata
- `MinimalFeedbackGroup`: Lightweight group interface
- `GroupOperationResult`: Result type for group operations

**Utilities:**
- `isFeedbackGroup`: Type guard for validation
- Type-safe group operations

## Usage Examples

### Basic Column Usage
```vue
<Column
  mode="positive"
  :feedback="positiveFeedback"
  :feedback-groups="positiveFeedbackGroups"
  phase="THEMING"
/>
```

### Using the Drag and Drop Composable
```typescript
import { useFeedbackDragDrop } from '@/composables/useFeedbackDragDrop'

const {
  draggedItemId,
  handleDragStart,
  handleDrop,
  isGroupingAllowed,
  ungroupedFeedback,
} = useFeedbackDragDrop({
  feedback: toRef(props, 'feedback'),
  feedbackGroups: toRef(props, 'feedbackGroups'),
  phase: toRef(props, 'phase'),
})
```

### Custom Feedback Item
```vue
<FeedbackItem
  :item="feedbackItem"
  :is-dragged="draggedItemId === feedbackItem.id"
  :is-draggable="phase === 'THEMING'"
  :show-grip="true"
  @drag-start="handleDragStart"
  @drag-end="handleDragEnd"
/>
```

## Drag and Drop Behavior

### Phase Restrictions
- **BRAINSTORMING**: Items are not draggable, no grouping allowed
- **THEMING**: Full drag and drop functionality enabled
- **Other phases**: Dragging disabled, groups displayed read-only

### Interaction Types

1. **Item to Item**: Creates a new group with both items
2. **Item to Group**: Adds the item to the existing group
3. **Grouped Item to Item**: Moves item from its group to create new group
4. **Grouped Item to Remove Zone**: Removes item from its group
5. **Ungrouped Item to Remove Zone**: Visual feedback only (no operation)

### Visual Feedback
- **Dragged items**: 30% opacity, grabbing cursor
- **Drop targets**: Green border and background
- **Group drop targets**: Purple border with scale effect
- **Remove zone**: Red styling with scale effect when active

## Best Practices

1. **Component Composition**: Use the provided components rather than implementing drag and drop manually
2. **Type Safety**: Import and use the proper TypeScript interfaces
3. **Event Handling**: Let the composable handle all drag logic, components should only emit events
4. **Performance**: The composable uses computed properties and efficient lookups for optimal performance
5. **Accessibility**: Components include proper ARIA attributes and keyboard navigation support

## Testing

When testing these components:
- Mock the `useFeedbackDragDrop` composable for unit tests
- Test drag and drop interactions with integration tests
- Verify phase-based restrictions are properly enforced
- Ensure proper event emission and prop handling

## Future Enhancements

Potential improvements for the feedback system:
- Keyboard navigation for drag and drop
- Undo/redo functionality for grouping operations
- Bulk operations for multiple items
- Custom group naming and metadata
- Animation improvements for better UX
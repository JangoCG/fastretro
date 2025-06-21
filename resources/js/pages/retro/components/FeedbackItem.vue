<template>
  <CompactCard
    :content="item.content"
    :is-draggable="isDraggable"
    :is-dragged="isDragged"
    :show-grip="showGrip"
    :is-highlighted="isHighlighted"
    :grip-size="gripSize"
    :card-class="combinedCardClasses"
    :padding-class="contentPadding"
    :text-size-class="textSize || 'text-sm'"
    @drag-start="handleDragStart"
    @drag-end="handleDragEnd"
  />
</template>

<script setup lang="ts">
import CompactCard from '@/components/CompactCard.vue'
import { type Feedback } from '@/types/model'
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight'
import { computed } from 'vue'

/**
 * Props for the FeedbackItem component
 */
interface Props {
  /** The feedback item to display */
  item: Feedback | FeedbackWithHighlight
  /** Column mode determining the type of feedback */
  mode?: 'positive' | 'negative'
  /** Whether the item is currently being dragged */
  isDragged?: boolean
  /** Whether the item can be dragged */
  isDraggable?: boolean
  /** Whether to show the grip handle */
  showGrip?: boolean
  /** Whether the item is in a group (affects styling) */
  isInGroup?: boolean
  /** Size of the grip icon */
  gripSize?: number
  /** Additional CSS classes for the card */
  cardClasses?: string
  /** Text size class for the content */
  textSize?: string
  /** Padding class for the content */
  contentPadding?: string
}

/**
 * Events emitted by the FeedbackItem component
 */
interface Emits {
  /** Emitted when drag starts */
  dragStart: [event: DragEvent, item: Feedback | FeedbackWithHighlight]
  /** Emitted when drag ends */
  dragEnd: [event: DragEvent]
}

const props = withDefaults(defineProps<Props>(), {
  isDragged: false,
  isDraggable: true,
  showGrip: true,
  isInGroup: false,
  gripSize: 16,
  cardClasses: '',
  textSize: '',
  contentPadding: 'px-4 py-3',
})

const emit = defineEmits<Emits>()

/**
 * Type guard to check if item has highlight property
 */
function hasHighlight(item: Feedback | FeedbackWithHighlight): item is FeedbackWithHighlight {
  return 'isHighlighted' in item
}

/**
 * Whether the item should be highlighted
 */
const isHighlighted = computed(() => {
  return hasHighlight(props.item) && props.item.isHighlighted
})

/**
 * Background class based on feedback type
 */
const backgroundClass = computed(() => {
  if (props.mode === 'positive') {
    return 'bg-green-100 border-green-600'
  } else if (props.mode === 'negative') {
    return 'bg-red-100 border-red-600'
  }
  return ''
})

/**
 * Combined card classes including background
 */
const combinedCardClasses = computed(() => {
  return [props.cardClasses, backgroundClass.value].filter(Boolean).join(' ')
})

/**
 * Handle drag start event
 */
function handleDragStart(event: DragEvent): void {
  emit('dragStart', event, props.item)
}

/**
 * Handle drag end event
 */
function handleDragEnd(event: DragEvent): void {
  emit('dragEnd', event)
}
</script>

<style scoped>
.cursor-grab {
  cursor: grab !important;
}

.cursor-grabbing {
  cursor: grabbing !important;
}

.cursor-default {
  cursor: default !important;
}
</style>
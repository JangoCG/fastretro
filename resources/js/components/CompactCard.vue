<template>
    <component
        :is="isDraggable ? 'div' : 'div'"
        :draggable="isDraggable"
        @dragstart="handleDragStart"
        @dragend="handleDragEnd"
        :class="[
            'rounded-md border-2 p-2 text-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] transition-all duration-150',
            cardClass || 'border-black bg-white',
            {
                'opacity-30': isDragged,
                'cursor-grabbing': isDragged,
                'cursor-grab': !isDragged && isDraggable,
                'hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px]': !isDragged && !noHover,
                'ring-6 ring-yellow-400 bg-yellow-200 shadow-[6px_6px_0px_0px_rgba(250,204,21,0.5)] border-yellow-500 scale-102 z-10': isHighlighted,
            },
        ]"
        :style="{ userSelect: isDraggable ? 'none' : 'auto' }"
    >
        <div :class="['flex items-start justify-between gap-3', paddingClass]">
            <!-- Main Content -->
            <div class="min-w-0 flex-1">
                <slot>
                    <p :class="['leading-snug break-words', textSizeClass]">{{ content }}</p>
                </slot>

                <!-- Metadata (author, etc) -->
                <div v-if="$slots.metadata || metadata" :class="['mt-1', metadataTextSizeClass]">
                    <slot name="metadata">
                        <span v-if="metadata">{{ metadata }}</span>
                    </slot>
                </div>
            </div>

            <!-- Right Side Content -->
            <div v-if="$slots.actions || showGrip" class="flex shrink-0 items-center gap-2">
                <slot name="actions" />
                <GripVertical v-if="showGrip" :size="gripSize" class="text-muted-foreground" />
            </div>
        </div>
    </component>
</template>

<script setup lang="ts">
import { GripVertical } from 'lucide-vue-next';

interface Props {
    /** The main content to display */
    content?: string;
    /** Metadata text (e.g., author name) */
    metadata?: string;
    /** Whether the card is currently being dragged */
    isDragged?: boolean;
    /** Whether the card can be dragged */
    isDraggable?: boolean;
    /** Whether to show the grip handle */
    showGrip?: boolean;
    /** Whether the card is highlighted */
    isHighlighted?: boolean;
    /** Size of the grip icon */
    gripSize?: number;
    /** Additional CSS classes for the card */
    cardClass?: string;
    /** Padding class for the content */
    paddingClass?: string;
    /** Text size class for the main content */
    textSizeClass?: string;
    /** Text size class for metadata */
    metadataTextSizeClass?: string;
    /** Disable hover effect */
    noHover?: boolean;
}

interface Emits {
    /** Emitted when drag starts */
    dragStart: [event: DragEvent];
    /** Emitted when drag ends */
    dragEnd: [event: DragEvent];
}

const props = withDefaults(defineProps<Props>(), {
    isDragged: false,
    isDraggable: false,
    showGrip: false,
    isHighlighted: false,
    gripSize: 14,
    cardClass: '',
    paddingClass: 'px-4 py-3',
    textSizeClass: 'text-sm',
    metadataTextSizeClass: 'text-xs text-muted-foreground',
    noHover: false,
});

const emit = defineEmits<Emits>();

function handleDragStart(event: DragEvent): void {
    if (props.isDraggable) {
        emit('dragStart', event);
    }
}

function handleDragEnd(event: DragEvent): void {
    if (props.isDraggable) {
        emit('dragEnd', event);
    }
}
</script>

<style scoped>
.cursor-grab {
    cursor: grab !important;
}

.cursor-grabbing {
    cursor: grabbing !important;
}
</style>

<template>
    <div
        v-show="isVisible"
        class="mb-4 rounded-lg border-2 border-dashed border-black bg-red-100 p-4 text-center transition-all duration-200"
        @dragover="handleDragOver"
        @dragenter="handleDragEnter"
        @dragleave="handleDragLeave"
        @drop="handleDrop"
        :class="{
            'is-remove-zone-active': isActive,
        }"
    >
        <div class="flex items-center justify-center gap-2">
            <div>️‍⛓️‍💥</div>
            <span class="text-sm font-bold text-black">
                {{ message }}
            </span>
        </div>
    </div>
</template>

<script setup lang="ts">
/**
 * Props for the RemoveZone component
 */
interface Props {
    /** Whether the remove zone should be visible */
    isVisible?: boolean;
    /** Whether the remove zone is currently active (being hovered over) */
    isActive?: boolean;
    /** Message to display in the remove zone */
    message?: string;
}

/**
 * Events emitted by the RemoveZone component
 */
interface Emits {
    /** Emitted when drag over occurs */
    dragOver: [event: DragEvent];
    /** Emitted when drag enters the zone */
    dragEnter: [event: DragEvent];
    /** Emitted when drag leaves the zone */
    dragLeave: [event: DragEvent];
    /** Emitted when drop occurs in the zone */
    drop: [event: DragEvent];
}

const props = withDefaults(defineProps<Props>(), {
    isVisible: false,
    isActive: false,
    message: 'Drop here to remove',
});

const emit = defineEmits<Emits>();

/**
 * Handle drag over event
 */
function handleDragOver(event: DragEvent): void {
    emit('dragOver', event);
}

/**
 * Handle drag enter event
 */
function handleDragEnter(event: DragEvent): void {
    emit('dragEnter', event);
}

/**
 * Handle drag leave event
 */
function handleDragLeave(event: DragEvent): void {
    emit('dragLeave', event);
}

/**
 * Handle drop event
 */
function handleDrop(event: DragEvent): void {
    emit('drop', event);
}
</script>

<style scoped>
@reference "tailwindcss";

/* Remove zone styling */
.is-remove-zone-active {
    @apply border-red-600 bg-red-200 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] ring-2 ring-black;
    transform: scale(1.02);
}
</style>

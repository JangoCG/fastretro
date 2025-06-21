<template>
    <CompactCard
        :content="action.content"
    >
        <template #actions>
            <div class="flex items-center text-green-600">
                <span class="text-sm">🎯</span>
            </div>
        </template>
    </CompactCard>
</template>

<script setup lang="ts">
import CompactCard from '@/components/CompactCard.vue'

/**
 * Props for the ActionItem component
 */
interface Props {
    /** The action item to display */
    action: any;
}

defineProps<Props>();
</script>

<style scoped>
/* Add any action item specific styles here */
</style>

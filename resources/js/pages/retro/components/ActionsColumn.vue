<template>
    <div class="w-full rounded-lg bg-white p-4 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
        <!-- Column Header -->
        <h2 class="mb-4 text-xl font-bold text-black">🎯 What actions do we take?</h2>

        <!-- Add New Action Form -->
        <div class="mb-6 space-y-3">
            <textarea
                v-model="newActionContent"
                placeholder="Describe an action item..."
                class="w-full min-h-[80px] px-4 py-3 border-2 border-black rounded-lg resize-none focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 focus:outline-none transition-colors"
                @keydown.ctrl.enter="addAction"
                @keydown.meta.enter="addAction"
            />
            <button 
                @click="addAction" 
                :disabled="!newActionContent.trim()" 
                class="w-full flex items-center justify-center gap-2 px-6 py-3 bg-yellow-400 text-black font-bold border-2 border-black rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[4px] hover:translate-y-[4px] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            >
                <span>➕</span>
                <span>Add Action</span>
            </button>
        </div>

        <!-- Existing Actions -->
        <div class="space-y-2">
            <ActionItem v-for="action in actions" :key="`action-${action.id}`" :action="action" />
        </div>
    </div>
</template>

<script setup lang="ts">
import { router } from '@inertiajs/vue3';
import { ref } from 'vue';
import ActionItem from './ActionItem.vue';

/**
 * Props for the ActionsColumn component
 */
interface Props {
    /** Array of actions for this retro */
    actions: any[];
    /** The retro ID for creating new actions */
    retroId: string;
}

const props = defineProps<Props>();

const newActionContent = ref('');

/**
 * Add a new action
 */
function addAction(): void {
    if (!newActionContent.value.trim()) {
        return;
    }

    router.post(
        route('actions.store', { retro: props.retroId }),
        {
            content: newActionContent.value.trim(),
            retro_id: props.retroId,
        },
        {
            preserveScroll: true,
            onSuccess: () => {
                newActionContent.value = '';
            },
            onError: (errors) => {
                console.error('Error adding action:', errors);
            },
        },
    );
}
</script>

<style scoped>
/* Add any column-specific styles here */
</style>

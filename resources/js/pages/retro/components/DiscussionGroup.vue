<template>
    <div class="discussion-group rounded-lg border-2 border-dashed border-yellow-400 bg-gradient-to-r from-yellow-50 to-yellow-100 p-3 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] border-black">
        <!-- Group Header with Vote Count -->
        <div class="mb-2 flex items-center justify-between">
            <div class="flex items-center gap-2">
                <div class="h-2 w-2 rounded-full bg-yellow-600"></div>
                <span class="text-sm font-semibold text-black"> Grouped Items</span>
                <div v-if="voteCount > 0" class="flex items-center gap-1 text-sm font-bold text-black">
                    <span>🗳️ {{ voteCount }}</span>
                </div>
            </div>
        </div>

        <!-- Feedback Items in Group -->
        <div class="space-y-1">
            <CompactCard
                v-for="item in group.feedbacks"
                :key="`group-item-${item.id}`"
                :content="item.content"
                :card-class="`border-2 border-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] ${backgroundClass}`"
                padding-class="px-3 py-2"
            />
        </div>
    </div>
</template>

<script setup lang="ts">
import CompactCard from '@/components/CompactCard.vue'
import { type FeedbackGroup } from '@/types/feedback-group';
import { computed } from 'vue';

/**
 * Props for the DiscussionGroup component
 */
interface Props {
    /** The feedback group to display */
    group: FeedbackGroup;
    /** Column mode determining the type of feedback */
    mode?: 'positive' | 'negative';
    /** Number of votes this group has received */
    voteCount: number;
}

const props = defineProps<Props>();

/**
 * Background class based on feedback type
 */
const backgroundClass = computed(() => {
  if (props.mode === 'positive') {
    return 'bg-green-100 border-green-600'
  } else if (props.mode === 'negative') {
    return 'bg-red-100 border-red-600'
  }
  return 'bg-white'
})
</script>

<style scoped>
/* Group container styling */
.discussion-group {
    position: relative;
}

.discussion-group::before {
    content: '';
    position: absolute;
    top: -2px;
    left: -2px;
    right: -2px;
    bottom: -2px;
    background: linear-gradient(45deg, #FACC15, #F59E0B);
    border-radius: 10px;
    z-index: -1;
    opacity: 0.1;
}
</style>

<template>
    <CompactCard
        :content="feedback.content"
        :card-class="backgroundClass"
    >
        <template #actions v-if="voteCount > 0">
            <div class="flex items-center font-bold text-black">
                <span class="text-sm">🗳️ {{ voteCount }}</span>
            </div>
        </template>
    </CompactCard>
</template>

<script setup lang="ts">
import CompactCard from '@/components/CompactCard.vue'
import { type Feedback } from '@/types/model';
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight';
import { computed } from 'vue';

/**
 * Props for the DiscussionFeedbackItem component
 */
interface Props {
    /** The feedback item to display */
    feedback: Feedback | FeedbackWithHighlight;
    /** Column mode determining the type of feedback */
    mode?: 'positive' | 'negative';
    /** Number of votes this feedback has received */
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
  return ''
})
</script>

<style scoped>
/* Add any feedback item specific styles here */
</style>

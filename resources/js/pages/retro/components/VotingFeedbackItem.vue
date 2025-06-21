<template>
    <CompactCard
        :content="feedback.content"
        :card-class="backgroundClass"
    >
        <template #actions>
            <!-- Vote Information and Button -->
            <div class="flex items-center gap-3">
                <!-- User's Own Vote Display -->
                <div v-if="userVoteCount > 0" class="flex items-center gap-1 text-sm font-bold text-green-600">
                    <span>❤️ {{ userVoteCount }}</span>
                </div>

                <!-- Vote/Unvote Button -->
                <div class="flex items-center gap-1">
                    <Button
                        v-if="canVote"
                        @click="$emit('vote', { type: 'feedback', id: feedback.id })"
                        class="bg-green-400 text-black border-2 border-black hover:bg-green-300 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all text-xs font-bold"
                        size="sm"
                    >
                        ❤️ Vote
                    </Button>

                    <Button
                        v-if="userVoteCount > 0"
                        @click="$emit('unvote', { type: 'feedback', id: feedback.id })"
                        class="bg-red-400 text-black border-2 border-black hover:bg-red-300 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all text-xs font-bold"
                        size="sm"
                    >
                        💔 Remove
                    </Button>
                </div>

                <Button v-if="!canVote && userVoteCount === 0" disabled class="bg-gray-200 text-black border-2 border-black text-xs font-bold opacity-50" size="sm">
                    <Heart :size="14" class="mr-1" />
                    No Votes Left
                </Button>
            </div>
        </template>
    </CompactCard>
</template>

<script setup lang="ts">
import CompactCard from '@/components/CompactCard.vue'
import { Button } from '@/components/ui/button';
import { type Feedback } from '@/types/model';
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight';
import { Heart } from 'lucide-vue-next';
import { computed } from 'vue';

/**
 * Props for the VotingFeedbackItem component
 */
interface Props {
    /** The feedback item to display */
    feedback: Feedback | FeedbackWithHighlight;
    /** Column mode determining the type of feedback */
    mode?: 'positive' | 'negative';
    /** Number of votes this feedback has received */
    voteCount: number;
    /** Number of votes the current user has cast for this feedback */
    userVoteCount: number;
    /** Whether the user can vote (has votes remaining) */
    canVote: boolean;
}

/**
 * Events emitted by the VotingFeedbackItem component
 */
interface Emits {
    /** Emitted when user votes for this feedback */
    vote: [];
    /** Emitted when user removes vote from this feedback */
    unvote: [];
}

const props = defineProps<Props>();
defineEmits<Emits>();

/**
 * Background class based on feedback type
 */
const backgroundClass = computed(() => {
  if (props.mode === 'positive') {
    return 'bg-green-100 border-black'
  } else if (props.mode === 'negative') {
    return 'bg-red-100 border-black'
  }
  return 'border-black bg-white'
})
</script>

<style scoped>
/* Add any feedback item specific styles here */
</style>

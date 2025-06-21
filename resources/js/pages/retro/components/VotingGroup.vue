<template>
  <div class="voting-group rounded-lg border-2 border-black bg-white p-4 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] transition-all duration-200">
    <!-- Group Header with Vote Button -->
    <div class="mb-3 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <div class="h-2 w-2 rounded-full bg-black"></div>
        <span class="text-sm font-bold text-black">
          Grouped Items ({{ group.feedbacks.length }})
        </span>
        <div v-if="userVoteCount > 0" class="flex items-center gap-1 text-xs font-bold text-green-600">
          <span>❤️ {{ userVoteCount }}</span>
        </div>
      </div>
      
      <!-- Vote/Unvote Button -->
      <div class="flex items-center gap-2">
        <div class="flex items-center gap-1">
          <Button
            v-if="canVote"
            @click="$emit('vote', { type: 'group', id: group.id })"
            class="bg-green-400 text-black border-2 border-black hover:bg-green-300 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all text-xs font-bold"
            size="sm"
          >
            ❤️ Vote
          </Button>
          
          <Button
            v-if="userVoteCount > 0"
            @click="$emit('unvote', { type: 'group', id: group.id })"
            class="bg-red-400 text-black border-2 border-black hover:bg-red-300 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all text-xs font-bold"
            size="sm"
          >
            💔 Remove
          </Button>
        </div>
        
        <Button
          v-if="!canVote && userVoteCount === 0"
          disabled
          class="bg-gray-200 text-black border-2 border-black text-xs font-bold opacity-50"
          size="sm"
        >
          <Heart :size="14" class="mr-1" />
          No Votes Left
        </Button>
      </div>
    </div>

    <!-- Feedback Items in Group -->
    <div class="space-y-1">
      <div
        v-for="item in group.feedbacks"
        :key="`group-item-${item.id}`"
        class="rounded-lg p-1 transition-all duration-150"
      >
        <div
          v-if="item && item.id"
          :class="['rounded-md border-2 border-black p-2 text-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] transition-all duration-150 hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px]', backgroundClass]"
        >
          <div class="flex items-center justify-between">
            <p class="text-sm leading-snug break-words">{{ item.content }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { type FeedbackGroup } from '@/types/feedback-group'
import { Heart } from 'lucide-vue-next'
import { computed } from 'vue'

/**
 * Props for the VotingGroup component
 */
interface Props {
  /** The feedback group to display */
  group: FeedbackGroup
  /** Column mode determining the type of feedback */
  mode?: 'positive' | 'negative'
  /** Number of votes this group has received */
  voteCount: number
  /** Number of votes the current user has cast for this group */
  userVoteCount: number
  /** Whether the user can vote (has votes remaining) */
  canVote: boolean
}

/**
 * Events emitted by the VotingGroup component
 */
interface Emits {
  /** Emitted when user votes for this group */
  vote: []
  /** Emitted when user removes vote from this group */
  unvote: []
}

const props = defineProps<Props>()
defineEmits<Emits>()

/**
 * Background class based on feedback type
 */
const backgroundClass = computed(() => {
  if (props.mode === 'positive') {
    return 'bg-green-100'
  } else if (props.mode === 'negative') {
    return 'bg-red-100'
  }
  return 'bg-white'
})
</script>

<style scoped>
/* Add any voting group specific styles here */
</style>
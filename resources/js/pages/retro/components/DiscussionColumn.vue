<template>
  <div class="w-full rounded-lg bg-white p-4 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
    <!-- Column Header -->
    <h2 class="mb-4 text-xl font-bold text-black">{{ title }}</h2>

    <!-- All Items Sorted by Vote Count -->
    <div class="space-y-4">
      <!-- Combined and sorted items -->
      <div
        v-for="item in sortedItems"
        :key="`${item.type}-${item.id}`"
        class="space-y-1"
      >
        <DiscussionGroup
          v-if="item.type === 'group'"
          :group="item.data"
          :mode="mode"
          :vote-count="item.voteCount"
        />
        
        <DiscussionFeedbackItem
          v-else
          :feedback="item.data"
          :mode="mode"
          :vote-count="item.voteCount"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { type Feedback } from '@/types/model'
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight'
import { type FeedbackGroup } from '@/types/feedback-group'
import { computed } from 'vue'
import DiscussionGroup from './DiscussionGroup.vue'
import DiscussionFeedbackItem from './DiscussionFeedbackItem.vue'

/**
 * Props for the DiscussionColumn component
 */
interface Props {
  /** Column mode determining the type of feedback */
  mode: 'positive' | 'negative'
  /** Array of feedback items to display */
  feedback: (Feedback | FeedbackWithHighlight)[]
  /** Array of feedback groups */
  feedbackGroups: FeedbackGroup[]
}

/**
 * Item type for sorting
 */
interface SortableItem {
  id: number
  type: 'group' | 'feedback'
  voteCount: number
  data: FeedbackGroup | Feedback | FeedbackWithHighlight
}

const props = defineProps<Props>()

/**
 * Column title based on mode
 */
const title = computed(() => 
  props.mode === 'positive' ? '✨ What went well?' : '💭 What could be better?'
)

/**
 * Set of all grouped feedback IDs for efficient lookups
 */
const groupedFeedbackIds = computed(() => {
  const ids = new Set<number>()
  props.feedbackGroups.forEach((group) => {
    group.feedbacks.forEach((feedback) => {
      ids.add(feedback.id)
    })
  })
  return ids
})

/**
 * Feedback items that are not in any group
 */
const ungroupedFeedback = computed(() => {
  return props.feedback.filter((item) => !groupedFeedbackIds.value.has(item.id))
})

/**
 * Get vote count for a specific feedback group
 * @param group The feedback group object
 * @returns Number of votes for the group
 */
function getGroupVoteCount(group: FeedbackGroup): number {
  return (group as any).votes_count || 0
}

/**
 * Get vote count for a specific feedback item
 * @param feedback The feedback object
 * @returns Number of votes for the feedback
 */
function getFeedbackVoteCount(feedback: Feedback | FeedbackWithHighlight): number {
  return (feedback as any).votes_count || 0
}

/**
 * All items (groups and individual feedback) sorted by vote count
 */
const sortedItems = computed(() => {
  const items: SortableItem[] = []
  
  // Add groups
  props.feedbackGroups.forEach(group => {
    items.push({
      id: group.id,
      type: 'group',
      voteCount: getGroupVoteCount(group),
      data: group
    })
  })
  
  // Add ungrouped feedback
  ungroupedFeedback.value.forEach(feedback => {
    items.push({
      id: feedback.id,
      type: 'feedback',
      voteCount: getFeedbackVoteCount(feedback),
      data: feedback
    })
  })
  
  // Sort by vote count descending
  return items.sort((a, b) => b.voteCount - a.voteCount)
})
</script>

<style scoped>
/* Add any column-specific styles here */
</style>
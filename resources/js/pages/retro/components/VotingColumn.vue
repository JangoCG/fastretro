<template>
  <div class="w-full rounded-lg bg-white p-4 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
    <!-- Column Header -->
    <h1 class="mb-4 text-xl font-bold text-black">{{ title }}</h1>

    <!-- Feedback Items -->
    <div class="space-y-4">
      <!-- Feedback Groups -->
      <div 
        v-for="group in feedbackGroups" 
        :key="`group-${group.id}`"
        class="space-y-1"
      >
        <VotingGroup
          :group="group"
          :mode="mode"
          :vote-count="getGroupVoteCount(group)"
          :user-vote-count="getUserVoteCountForGroup(group.id)"
          :can-vote="remainingVotes > 0"
          @vote="$emit('vote', { type: 'group', id: group.id })"
          @unvote="$emit('unvote', { type: 'group', id: group.id })"
        />
      </div>

      <!-- Individual Feedback Items (not in groups) -->
      <div
        v-for="item in ungroupedFeedback"
        :key="`feedback-${item.id}`"
        class="space-y-1"
      >
        <VotingFeedbackItem
          :feedback="item"
          :mode="mode"
          :vote-count="getFeedbackVoteCount(item)"
          :user-vote-count="getUserVoteCountForFeedback(item.id)"
          :can-vote="remainingVotes > 0"
          @vote="$emit('vote', { type: 'feedback', id: item.id })"
          @unvote="$emit('unvote', { type: 'feedback', id: item.id })"
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
import VotingGroup from './VotingGroup.vue'
import VotingFeedbackItem from './VotingFeedbackItem.vue'

/**
 * Props for the VotingColumn component
 */
interface Props {
  /** Column mode determining the type of feedback */
  mode: 'positive' | 'negative'
  /** Array of feedback items to display */
  feedback: (Feedback | FeedbackWithHighlight)[]
  /** Array of feedback groups */
  feedbackGroups: FeedbackGroup[]
  /** Current participant's votes */
  participantVotes: any[]
  /** Remaining votes for the participant */
  remainingVotes: number
}

/**
 * Events emitted by the VotingColumn component
 */
interface Emits {
  /** Emitted when user votes for an item */
  vote: [payload: { type: 'feedback' | 'group'; id: number }]
  /** Emitted when user removes a vote */
  unvote: [payload: { type: 'feedback' | 'group'; id: number }]
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

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
 * Get total vote count for a specific feedback group (from all participants)
 * @param group The feedback group object
 * @returns Total number of votes for the group
 */
function getGroupVoteCount(group: any): number {
  return group.votes_count || 0
}

/**
 * Get total vote count for a specific feedback item (from all participants)
 * @param feedback The feedback object
 * @returns Total number of votes for the feedback
 */
function getFeedbackVoteCount(feedback: any): number {
  return feedback.votes_count || 0
}

/**
 * Get the number of votes the current user has cast for a specific group
 * @param groupId The ID of the feedback group
 * @returns Number of votes user has cast for this group
 */
function getUserVoteCountForGroup(groupId: number): number {
  return props.participantVotes.filter(vote => 
    vote.feedback_group_id === groupId
  ).length
}

/**
 * Get the number of votes the current user has cast for a specific feedback item
 * @param feedbackId The ID of the feedback item
 * @returns Number of votes user has cast for this feedback
 */
function getUserVoteCountForFeedback(feedbackId: number): number {
  return props.participantVotes.filter(vote => 
    vote.feedback_id === feedbackId
  ).length
}

</script>

<style scoped>
/* Add any column-specific styles here */
</style>
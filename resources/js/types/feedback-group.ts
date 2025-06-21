import { type Feedback } from '@/types/model'
import { type FeedbackWithHighlight } from '@/pages/retro/components/feedback-with-highlight'

/**
 * Represents a group of related feedback items
 */
export interface FeedbackGroup {
  /** Unique identifier for the group */
  id: number
  /** Array of feedback items in this group */
  feedbacks: (Feedback | FeedbackWithHighlight)[]
  /** ID of the retro this group belongs to */
  retro_id?: number
  /** Timestamp when the group was created */
  created_at?: string
  /** Timestamp when the group was last updated */
  updated_at?: string
}

/**
 * Type for feedback group with minimal required properties
 */
export type MinimalFeedbackGroup = Pick<FeedbackGroup, 'id' | 'feedbacks'>

/**
 * Type guard to check if an object is a valid feedback group
 */
export function isFeedbackGroup(obj: any): obj is FeedbackGroup {
  return (
    obj &&
    typeof obj === 'object' &&
    typeof obj.id === 'number' &&
    Array.isArray(obj.feedbacks)
  )
}

/**
 * Utility type for group operations
 */
export interface GroupOperationResult {
  success: boolean
  message?: string
  group?: FeedbackGroup
}
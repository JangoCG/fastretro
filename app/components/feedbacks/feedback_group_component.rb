class Feedbacks::FeedbackGroupComponent < ApplicationComponent
  def initialize(group:, feedbacks:, grouping_enabled: false, voting_enabled: false, show_votes: false, participant: nil, retro: nil)
    @group = group
    @feedbacks = feedbacks
    @grouping_enabled = grouping_enabled
    @voting_enabled = voting_enabled
    @show_votes = show_votes
    @participant = participant
    @retro = retro || @group.retro
  end

  def author_user_ids
    @feedbacks.map(&:user_id).uniq.join(",")
  end

  def feedback_highlighted?(feedback)
    @retro.highlighted_user_id.present? && feedback.user_id == @retro.highlighted_user_id
  end

  def feedback_dimmed?(feedback)
    @retro.highlighted_user_id.present? && feedback.user_id != @retro.highlighted_user_id
  end

  def discussed?
    @group.discussed?
  end

  private

  def primary_feedback
    @feedbacks.min_by(&:created_at)
  end

  def other_feedbacks
    @feedbacks.reject { |f| f == primary_feedback }
  end

  def category
    primary_feedback&.category
  end

  def show_voting?
    @voting_enabled && @participant.present?
  end

  def show_vote_count?
    @show_votes
  end

  def discussion_enabled?
    @retro.discussion?
  end

  def can_mark_discussed?
    discussion_enabled? && @retro.admin?(Current.user)
  end
end

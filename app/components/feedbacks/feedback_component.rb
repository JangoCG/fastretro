class Feedbacks::FeedbackComponent < ApplicationComponent
  def initialize(feedback:, draggable: false, grouping_enabled: false, voting_enabled: false, show_votes: false, participant: nil, retro: nil)
    @feedback = feedback
    @draggable = draggable
    @grouping_enabled = grouping_enabled
    @voting_enabled = voting_enabled
    @show_votes = show_votes
    @participant = participant
    @retro = retro || @feedback.retro
  end

  def in_group?
    @feedback.feedback_group.present?
  end

  def highlighted?
    @retro.highlighted_user_id.present? && @feedback.user_id == @retro.highlighted_user_id
  end

  def dimmed?
    @retro.highlighted_user_id.present? && @feedback.user_id != @retro.highlighted_user_id
  end

  private

  def can_edit?
    @feedback.user == Current.user
  end

  def show_voting?
    @voting_enabled && @participant.present? && !in_group?
  end

  def show_vote_count?
    @show_votes && !in_group?
  end
end

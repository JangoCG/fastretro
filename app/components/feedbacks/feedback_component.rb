class Feedbacks::FeedbackComponent < ApplicationComponent
  def initialize(feedback:, draggable: false, grouping_enabled: false, participant: nil, retro: nil)
    @feedback = feedback
    @draggable = draggable
    @grouping_enabled = grouping_enabled
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

  def discussed?
    @feedback.discussed?
  end

  private

  def can_edit?
    @feedback.user == Current.user
  end

  def discussion_enabled?
    @retro.discussion?
  end

  def can_mark_discussed?
    discussion_enabled? && !in_group? && @retro.admin?(Current.user)
  end
end

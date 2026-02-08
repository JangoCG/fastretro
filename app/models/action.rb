class Action < ApplicationRecord
  include Action::Statuses

  belongs_to :retro
  belongs_to :user, default: -> { Current.user }

  after_commit :broadcast_targeted_actions

  has_rich_text :content

  scope :incomplete, -> { where(completed: false) }
  scope :completed_actions, -> { where(completed: true) }

  def toggle_completion!
    update!(completed: !completed)
  end

  private

  def broadcast_targeted_actions
    return unless broadcast_actions?
    return unless retro.present?

    if retro.action_review?
      Turbo::StreamsChannel.broadcast_replace_to(
        retro,
        target: "action-review-grid",
        partial: "retros/action_reviews/actions_grid",
        locals: { retro: }
      )
    elsif retro.discussion?
      Turbo::StreamsChannel.broadcast_replace_to(
        retro,
        target: "actions-column",
        partial: "retros/streams/actions_column",
        locals: { retro: }
      )
    end
  end

  def broadcast_actions?
    return true if published?

    saved_change_to_status? && status_before_last_save == "published"
  end
end

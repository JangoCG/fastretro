class FeedbackGroup < ApplicationRecord
  belongs_to :retro
  has_many :feedbacks, dependent: :nullify

  after_commit :broadcast_targeted_columns

  def primary_feedback
    feedbacks.order(:created_at).first
  end

  private

  def broadcast_targeted_columns
    return if Current.skip_targeted_broadcasts
    return unless retro.present?

    participants = participants_for_broadcast
    return if participants.empty?

    shared_feedbacks_by_category = retro.brainstorming? ? nil : preload_feedbacks_by_category

    participants.each do |participant|
      user = participant.user
      feedbacks_by_category = shared_feedbacks_by_category || preload_feedbacks_by_category(user:)

      Current.set(account: retro.account, user:) do
        retro.column_categories.each do |target_category|
          Turbo::StreamsChannel.broadcast_replace_to(
            [ retro, user ],
            target: "retro-column-#{target_category}",
            attributes: { method: :morph },
            partial: "retros/streams/column",
            locals: { retro:, category: target_category, participant:, feedbacks_by_category: }
          )
        end
      end
    end
  end

  def participants_for_broadcast
    retro.participants.includes(:user).select { |participant| participant.user.present? }
  end

  def preload_feedbacks_by_category(user: nil)
    scope = retro.feedbacks.published
    scope = scope.where(user:) if retro.brainstorming? && user.present?

    scope.includes(:user, :rich_text_content, :feedback_group).to_a.group_by(&:category)
  end
end

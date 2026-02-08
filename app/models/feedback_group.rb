class FeedbackGroup < ApplicationRecord
  belongs_to :retro
  has_many :feedbacks, dependent: :nullify
  has_many :votes, as: :voteable, dependent: :destroy

  after_commit :broadcast_targeted_columns

  def primary_feedback
    feedbacks.order(:created_at).first
  end

  private

  def broadcast_targeted_columns
    return unless retro.present?

    each_retro_user do |user|
      Current.set(account: retro.account, user:) do
        %w[went_well could_be_better].each do |target_category|
          Turbo::StreamsChannel.broadcast_replace_to(
            [ retro, user ],
            target: "retro-column-#{target_category}",
            partial: "retros/streams/column",
            locals: { retro:, category: target_category }
          )
        end
      end
    end
  end

  def each_retro_user(&)
    retro.participants.includes(:user).each do |participant|
      next unless participant.user.present?

      yield(participant.user)
    end
  end
end

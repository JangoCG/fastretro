class Feedback < ApplicationRecord
  include Feedback::Statuses

  belongs_to :retro
  belongs_to :user, default: -> { Current.user }
  belongs_to :feedback_group, optional: true
  has_many :votes, as: :voteable, dependent: :destroy

  after_commit :broadcast_targeted_columns

  has_rich_text :content

  validates :category, presence: true
  validate :category_exists_in_retro

  scope :in_category, ->(cat) { where(category: cat) }
  scope :went_well, -> { in_category("went_well") }
  scope :could_be_better, -> { in_category("could_be_better") }

  def went_well?
    category == "went_well"
  end

  def could_be_better?
    category == "could_be_better"
  end

  private

  def category_exists_in_retro
    return unless retro.present?
    return if retro.category_exists?(category)

    errors.add(:category, "is not part of this retro layout")
  end

  def broadcast_targeted_columns
    return if Current.skip_targeted_broadcasts
    return unless broadcast_columns?

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
            partial: "retros/streams/column",
            locals: { retro:, category: target_category, participant:, feedbacks_by_category: }
          )
        end
      end
    end
  end

  def broadcast_columns?
    return false unless retro.present?
    return true if published?

    saved_change_to_status? && status_before_last_save == "published"
  end

  def participants_for_broadcast
    participants = retro.participants.includes(:user).select { |participant| participant.user.present? }
    return participants unless retro.brainstorming?

    participants.select { |participant| participant.user_id == user_id }
  end

  def preload_feedbacks_by_category(user: nil)
    scope = retro.feedbacks.published
    scope = scope.where(user:) if retro.brainstorming? && user.present?

    associations = [ :user, :rich_text_content, :feedback_group ]
    if retro.voting? || retro.discussion?
      associations += [ :votes, { feedback_group: :votes } ]
    end

    scope.includes(*associations).to_a.group_by(&:category)
  end
end

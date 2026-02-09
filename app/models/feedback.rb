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

    each_retro_user do |user|
      Current.set(account: retro.account, user:) do
        retro.column_categories.each do |target_category|
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

  def broadcast_columns?
    return false unless retro.present?
    return true if published?

    saved_change_to_status? && status_before_last_save == "published"
  end

  def each_retro_user(&)
    retro.participants.includes(:user).each do |participant|
      next unless participant.user.present?

      yield(participant.user)
    end
  end
end

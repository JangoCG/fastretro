class Feedback < ApplicationRecord
  include Feedback::Statuses

  belongs_to :retro
  belongs_to :user, default: -> { Current.user }
  belongs_to :feedback_group, optional: true
  has_many :votes, as: :voteable, dependent: :destroy

  broadcasts_refreshes_to :retro

  has_rich_text :content

  enum :category, { went_well: "went_well", could_be_better: "could_be_better" }

  scope :in_category, ->(cat) { where(category: cat) }
end

class FeedbackGroup < ApplicationRecord
  belongs_to :retro
  has_many :feedbacks, dependent: :nullify
  has_many :votes, as: :voteable, dependent: :destroy

  broadcasts_refreshes_to :retro

  def primary_feedback
    feedbacks.order(:created_at).first
  end
end

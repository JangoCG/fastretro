class Vote < ApplicationRecord
  belongs_to :retro_participant, class_name: "Retro::Participant", inverse_of: :votes
  belongs_to :voteable, polymorphic: true

  validate :participant_vote_limit, on: :create

  private

  def participant_vote_limit
    if retro_participant.votes.count >= 3
      errors.add(:base, "Maximum 3 votes per participant")
    end
  end
end

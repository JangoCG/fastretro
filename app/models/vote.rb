class Vote < ApplicationRecord
  belongs_to :retro_participant, class_name: "Retro::Participant", inverse_of: :votes
  belongs_to :voteable, polymorphic: true

  validate :participant_vote_limit, on: :create

  private

  def participant_vote_limit
    max_votes = retro_participant.retro.max_votes_per_participant
    if retro_participant.votes.count >= max_votes
      errors.add(:base, "Maximum #{max_votes} votes per participant")
    end
  end
end

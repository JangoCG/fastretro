class VotesRemainingComponent < ApplicationComponent
  attr_reader :participant, :retro

  def initialize(participant:, retro:)
    @participant = participant
    @retro = retro
  end

  def dom_id
    "votes_remaining_#{participant.id}"
  end

  def votes_remaining
    [ retro.max_votes_per_participant - participant.votes.size, 0 ].max
  end

  def render?
    participant.present?
  end
end

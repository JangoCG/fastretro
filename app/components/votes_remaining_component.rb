class VotesRemainingComponent < ApplicationComponent
  attr_reader :participant

  def initialize(participant:)
    @participant = participant
  end

  def dom_id
    "votes_remaining_#{participant.id}"
  end

  def votes_remaining
    3 - participant.votes.count
  end

  def render?
    participant.present?
  end
end

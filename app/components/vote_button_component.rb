# Renders a vote button for a Feedback or FeedbackGroup.
#
# Shows:
# - "-" button (if user has voted on this item)
# - Vote count badge (with user's contribution highlighted)
# - "+" button (if user has votes remaining)
#
# == Important: can_add_vote? is a global condition
#
# The "+" button visibility depends on participant.votes.count < 3, which is
# NOT specific to this voteable. This means when a user exhausts their votes,
# ALL VoteButtonComponents need to be re-rendered to hide their "+" buttons.
#
# The VotesController handles this via "threshold crossing" detection—see
# Retros::VotesController#render_vote_button_update for details.
#
# @see Retros::VotesController#render_vote_button_update
class VoteButtonComponent < ApplicationComponent
  attr_reader :voteable, :participant, :retro

  def initialize(voteable:, participant:, retro:)
    @voteable = voteable
    @participant = participant
    @retro = retro
  end

  def dom_id
    "vote_button_#{voteable.class.name.underscore}_#{voteable.id}"
  end

  def vote_count_dom_id
    "vote_count_#{voteable.class.name.underscore}_#{voteable.id}"
  end

  private

  def total_votes
    @voteable.votes.count
  end

  def user_votes
    @user_votes ||= @participant.votes.where(voteable: @voteable)
  end

  def user_vote_count
    user_votes.count
  end

  # Whether the participant can cast another vote (has < 3 total votes).
  # NOTE: This is a GLOBAL condition, not specific to this voteable.
  # When this changes, ALL vote buttons on the page need re-rendering.
  def can_add_vote?
    @participant.votes.count < 3
  end

  def can_remove_vote?
    user_vote_count > 0
  end

  def first_user_vote
    user_votes.first
  end

  def vote_path
    retro_votes_path(@retro)
  end

  def remove_vote_path(vote)
    retro_vote_path(@retro, vote)
  end

  def voteable_type
    @voteable.class.name
  end

  def voteable_id
    @voteable.id
  end
end

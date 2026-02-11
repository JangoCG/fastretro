# Handles voting on Feedbacks and FeedbackGroups during a retro's voting phase.
#
# Each participant has a retro-specific vote limit they can distribute across items.
# Uses targeted Turbo Stream updates for instant feedback (see docs/turbo-patterns-guide.md).
#
# == Vote Button Update Strategy
#
# The VoteButtonComponent shows/hides the "+" button based on whether the participant
# has votes remaining (participant.votes.count < limit). This creates a challenge:
#
# When a user casts their 3rd vote, we can't just update the clicked button—ALL other
# buttons on the page still show "+" because they haven't been re-rendered. Similarly,
# when removing a vote to go from 3→2, all buttons need to show "+" again.
#
# Solution: Track vote count before/after the action. If we cross the threshold (2↔3),
# update ALL vote buttons. Otherwise, just update the clicked button (more efficient).
#
# @see VoteButtonComponent#can_add_vote?
# @see docs/turbo-patterns-guide.md
class Retros::VotesController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :set_current_participant
  before_action :set_voteable, only: :create
  before_action :ensure_voting_phase

  def create
    # Capture vote count BEFORE the action to detect threshold crossings
    votes_before = @current_participant.votes.size

    return render_vote_button_update(:not_found, votes_before:) unless @voteable

    if votes_before >= max_votes_per_participant
      Rails.logger.warn "Vote limit reached: participant #{@current_participant.id} reached #{max_votes_per_participant} votes"
      return render_vote_button_update(:unprocessable_entity, votes_before:)
    end

    @vote = @current_participant.votes.build(voteable: @voteable)

    if @vote.save
      refresh_voteable_votes!
      broadcast_vote_total_update
      render_vote_button_update(:ok, votes_before:)
    else
      Rails.logger.error "Vote save failed: #{@vote.errors.full_messages.join(', ')}"
      render_vote_button_update(:unprocessable_entity, votes_before:)
    end
  end

  def destroy
    # Capture vote count BEFORE the action to detect threshold crossings
    votes_before = @current_participant.votes.size

    @vote = @current_participant.votes.find_by(id: params[:id])
    unless @vote
      return render_vote_button_update(:not_found, votes_before:)
    end

    @voteable = @vote.voteable
    @vote.destroy
    refresh_voteable_votes!
    broadcast_vote_total_update
    render_vote_button_update(:ok, votes_before:)
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def set_current_participant
    @current_participant = @retro.participants.includes(:votes).find_by(user: Current.user)
    @current_participant&.votes&.load
  end

  def set_voteable
    @voteable = find_voteable
  end

  def ensure_voting_phase
    unless @retro.voting?
      redirect_to retro_path(@retro), alert: "Voting is only available during the voting phase"
    end
  end

  def find_voteable
    case params[:voteable_type]
    when "Feedback"
      @retro.feedbacks.published.includes(:votes).find_by(id: params[:voteable_id])
    when "FeedbackGroup"
      @retro.feedback_groups
        .joins(:feedbacks)
        .merge(@retro.feedbacks.published)
        .includes(:votes)
        .distinct
        .find_by(id: params[:voteable_id])
    end
  end

  def broadcast_vote_total_update
    return unless @voteable

    Turbo::StreamsChannel.broadcast_update_to(
      @retro,
      target: vote_total_dom_id(@voteable),
      html: @voteable.votes.size.to_s
    )
  end

  # Renders Turbo Stream updates for vote buttons after a vote action.
  #
  # This method handles the "threshold crossing" problem: VoteButtonComponent decides
  # whether to show the "+" button based on participant.votes.count < limit. When a user
  # uses their last vote (or regains a vote), ALL buttons need updating, not just
  # the one they clicked.
  #
  # @param status [Symbol] HTTP status (:ok, :not_found, :unprocessable_entity)
  # @param votes_before [Integer] participant's vote count before the action
  #
  # == Threshold Crossing Logic
  #
  #   votes_before=2, votes_after=3 → crossed threshold (used last vote)
  #     → Update ALL buttons to hide "+" icons
  #
  #   votes_before=3, votes_after=2 → crossed threshold (regained a vote)
  #     → Update ALL buttons to show "+" icons
  #
  #   votes_before=1, votes_after=2 → no threshold crossing
  #     → Update only the clicked button (efficient)
  #
  def render_vote_button_update(status, votes_before:)
    @current_participant.votes.reset
    @current_participant.votes.load
    votes_after = @current_participant.votes.size

    # Did we cross the max votes threshold? If so, ALL buttons need updating.
    # - Going 2→3: all "+" buttons must disappear (no votes left)
    # - Going 3→2: all "+" buttons must reappear (votes available again)
    crossed_threshold = (votes_before < max_votes_per_participant && votes_after >= max_votes_per_participant) ||
                        (votes_before >= max_votes_per_participant && votes_after < max_votes_per_participant)
    voteables_for_threshold = crossed_threshold ? all_voteables : nil

    respond_to do |format|
      format.turbo_stream do
        streams = []

        if crossed_threshold
          # Threshold crossed: update ALL vote buttons on the page.
          # We iterate through every voteable (Feedback + FeedbackGroup) and send
          # a turbo_stream.replace for each one. This ensures all "+" buttons
          # appear/disappear consistently.
          voteables_for_threshold.each do |voteable|
            vote_button = VoteButtonComponent.new(
              voteable: voteable,
              participant: @current_participant,
              retro: @retro
            )
            streams << turbo_stream.replace(vote_button.dom_id, vote_button)
          end
        elsif @voteable
          # No threshold crossed: only update the button that was clicked.
          # This is the common case (voting 0→1, 1→2, 2→1, 1→0) and keeps
          # the response payload small for snappy feedback.
          vote_button = VoteButtonComponent.new(
            voteable: @voteable,
            participant: @current_participant,
            retro: @retro
          )
          streams << turbo_stream.replace(vote_button.dom_id, vote_button)
        end

        # Always update the "votes remaining" counter in the header
        votes_remaining = VotesRemainingComponent.new(participant: @current_participant, retro: @retro)
        streams << turbo_stream.replace(votes_remaining.dom_id, votes_remaining)

        render turbo_stream: streams, status: status
      end
      format.html { redirect_to retro_voting_path(@retro) }
    end
  end

  # Returns all voteable items (Feedbacks and FeedbackGroups) for this retro.
  # Used when we need to update all vote buttons after a threshold crossing.
  # Eager-loads votes to avoid N+1 queries when rendering VoteButtonComponents.
  def all_voteables
    return @all_voteables if defined?(@all_voteables)

    feedbacks = @retro.feedbacks.published.includes(:votes).to_a
    feedback_group_ids = feedbacks.filter_map(&:feedback_group_id).uniq
    feedback_groups = @retro.feedback_groups.where(id: feedback_group_ids).includes(:votes).to_a

    @all_voteables = feedbacks + feedback_groups
  end

  def refresh_voteable_votes!
    return unless @voteable

    @voteable.association(:votes).reset
    @voteable.votes.load
  end

  def vote_total_dom_id(voteable)
    "vote_total_#{voteable.class.name.underscore}_#{voteable.id}"
  end

  def max_votes_per_participant
    @retro.max_votes_per_participant
  end
end

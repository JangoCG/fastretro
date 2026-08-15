# Records balloons popped in the celebration game of a retro's complete phase.
#
# The browser batches pops and posts them every second or so, which keeps the
# request rate sane while everyone plays at the same time. Recording a batch
# broadcasts the shared highscore to every connected client.
class Retros::BalloonPopsController < ApplicationController
  include RetroAuthorization

  # A playing browser posts once a second, so this leaves generous headroom while
  # still bounding a client that skips the game and posts batches in a loop. Keyed
  # by player: a whole team behind one office IP must not share one bucket.
  rate_limit to: 120, within: 1.minute, only: :create,
    by: -> { Current.user&.id }, with: -> { head :too_many_requests }

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :set_current_participant
  before_action :ensure_complete_phase

  def create
    @current_participant.pop_balloons(params[:count])

    head :created
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def set_current_participant
    @current_participant = @retro.participants.find_by!(user: Current.user)
  end

  def ensure_complete_phase
    head :unprocessable_entity unless @retro.complete?
  end
end

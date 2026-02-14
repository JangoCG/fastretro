class Retros::WaitingRoomsController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  layout "application"

  before_action :set_retro
  before_action :ensure_retro_participant

  def show
    unless @retro.waiting_room?
      redirect_to phase_path_for(@retro) and return
    end

    @participants = @retro.participants.includes(:user).order(:created_at).to_a
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

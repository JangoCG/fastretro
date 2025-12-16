class Retros::FinishedsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_participant

  def update
    @participant = @retro.participants.find_by!(user: Current.user)
    @participant.toggle_finished!
    redirect_back fallback_location: retro_path(@retro), status: :see_other
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

class Retros::WaitingRoomsController < ApplicationController
  include RetroAuthorization

  layout "application"

  before_action :set_retro
  before_action :ensure_retro_participant

  def show
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

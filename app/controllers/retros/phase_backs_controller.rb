class Retros::PhaseBacksController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    @retro.back_phase!
    broadcast_phase_redirect
    redirect_to phase_path_for(@retro)
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

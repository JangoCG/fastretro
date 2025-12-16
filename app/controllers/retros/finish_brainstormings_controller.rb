class Retros::FinishBrainstormingsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    @retro.finish_brainstorming!
    redirect_to retro_brainstorming_path(@retro)
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

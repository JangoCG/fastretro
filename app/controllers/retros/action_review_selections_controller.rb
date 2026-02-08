class Retros::ActionReviewSelectionsController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    if params[:skip] == "true"
      @retro.start!(skip_action_review: true)
      broadcast_phase_redirect(retro_brainstorming_path(@retro))
      redirect_to retro_brainstorming_path(@retro)
    else
      source_retro = Current.account.retros.find(params[:source_retro_id])
      @retro.import_actions_from(source_retro)
      @retro.start!(skip_action_review: false)
      broadcast_phase_redirect(retro_action_review_path(@retro))
      redirect_to retro_action_review_path(@retro)
    end
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

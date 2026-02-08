class Retros::StartsController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    if Current.account.has_completed_retros_with_actions?
      @past_retros = Current.account.retros.completed_with_actions.limit(20)
      render turbo_stream: turbo_stream.replace(
        "start-retro-container",
        partial: "retros/starts/action_review_selection_modal",
        locals: {
          retro: @retro,
          past_retros: @past_retros
        }
      )
    else
      @retro.start!(skip_action_review: true)
      broadcast_phase_redirect(retro_brainstorming_path(@retro))
      redirect_to retro_brainstorming_path(@retro)
    end
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

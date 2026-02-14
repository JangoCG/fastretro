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
      target_url = retro_brainstorming_path(@retro)
      broadcast_phase_redirect(target_url)

      if turbo_frame_request?
        render turbo_stream: %(<turbo-stream action="redirect" url="#{target_url}"></turbo-stream>)
      else
        redirect_to target_url
      end
    end
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end
end

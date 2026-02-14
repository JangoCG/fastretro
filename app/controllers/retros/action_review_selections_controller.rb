class Retros::ActionReviewSelectionsController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    if params[:skip] == "true"
      @retro.start!(skip_action_review: true)
      target_url = retro_brainstorming_path(@retro)
      broadcast_phase_redirect(target_url)

      if turbo_frame_request?
        render turbo_stream: %(<turbo-stream action="redirect" url="#{target_url}"></turbo-stream>)
      else
        redirect_to target_url
      end
    else
      source_retro = Current.account.retros.find(params[:source_retro_id])
      @retro.import_actions_from(source_retro)
      @retro.start!(skip_action_review: false)
      target_url = retro_action_review_path(@retro)
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

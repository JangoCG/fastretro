class Retros::ActionReviewSelectionsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    if params[:skip] == "true"
      @retro.start!(skip_action_review: true)
      broadcast_redirect(retro_brainstorming_path(@retro))
      redirect_to retro_brainstorming_path(@retro)
    else
      source_retro = Current.account.retros.find(params[:source_retro_id])
      @retro.import_actions_from(source_retro)
      @retro.start!(skip_action_review: false)
      broadcast_redirect(retro_action_review_path(@retro))
      redirect_to retro_action_review_path(@retro)
    end
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def broadcast_redirect(url)
    Turbo::StreamsChannel.broadcast_stream_to(
      @retro,
      content: %(<turbo-stream action="redirect" url="#{url}"></turbo-stream>)
    )
  end
end

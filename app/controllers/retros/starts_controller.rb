class Retros::StartsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    @retro.start!
    broadcast_phase_redirect
    redirect_to retro_brainstorming_path(@retro)
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def broadcast_phase_redirect
    redirect_url = retro_brainstorming_path(@retro)
    Turbo::StreamsChannel.broadcast_stream_to(
      @retro,
      content: %(<turbo-stream action="redirect" url="#{redirect_url}"></turbo-stream>)
    )
  end
end

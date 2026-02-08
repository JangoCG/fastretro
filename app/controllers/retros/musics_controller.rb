class Retros::MusicsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :ensure_retro_admin

  def update
    @retro.update!(music_playing: !@retro.music_playing)
    broadcast_music_state

    head :ok
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def broadcast_music_state
    Turbo::StreamsChannel.broadcast_action_to(
      @retro,
      action: :music,
      attributes: { state: @retro.music_playing ? "playing" : "stopped" }
    )
  end
end

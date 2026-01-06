class Retros::MusicsController < ApplicationController
  before_action :set_retro
  before_action :ensure_participant
  before_action :ensure_admin

  def update
    @retro.update!(music_playing: !@retro.music_playing)
    broadcast_music_state

    head :ok
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def ensure_participant
    redirect_to retros_path unless @retro.participant?(Current.user)
  end

  def ensure_admin
    head :forbidden unless @retro.admin?(Current.user)
  end

  def broadcast_music_state
    Turbo::StreamsChannel.broadcast_action_to(
      @retro,
      action: :music,
      attributes: { state: @retro.music_playing ? "playing" : "stopped" }
    )
  end
end

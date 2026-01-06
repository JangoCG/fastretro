class MusicToggleComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  private

  def playing?
    @retro.music_playing?
  end
end

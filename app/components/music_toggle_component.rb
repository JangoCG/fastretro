class MusicToggleComponent < ApplicationComponent
  def initialize(retro:, style: :stack)
    @retro = retro
    @style = style.to_sym
  end

  private

  def playing?
    @retro.music_playing?
  end

  def inline?
    @style == :inline
  end

  def topbar?
    @style == :topbar
  end
end

class Actions::AddActionButtonComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  private

  def hotkey
    "A"
  end
end

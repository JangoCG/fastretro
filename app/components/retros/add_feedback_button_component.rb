class Retros::AddFeedbackButtonComponent < ApplicationComponent
  def initialize(retro:, category:)
    @retro = retro
    @category = category
  end

  private

  def hotkey
    @category == "went_well" ? "W" : "B"
  end
end

class Actions::ColumnComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  private

  def actions
    @actions ||= @retro.actions.published
  end

  def title
    "Actions"
  end
end

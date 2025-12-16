class Actions::ActionComponent < ApplicationComponent
  def initialize(action:)
    @action = action
  end

  private

  def can_edit?
    @action.user == Current.user
  end
end

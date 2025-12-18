class Actions::CompletionsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :set_action

  def update
    @action.toggle_completion!
    head :ok
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def set_action
    @action = @retro.actions.find(params[:action_id])
  end
end

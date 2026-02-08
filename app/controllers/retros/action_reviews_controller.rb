class Retros::ActionReviewsController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  layout "retro"

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :set_current_participant

  def show
    unless @retro.action_review?
      redirect_to phase_path_for(@retro) and return
    end
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def set_current_participant
    @current_participant = @retro.participants.find_by(user: Current.user)
  end
end

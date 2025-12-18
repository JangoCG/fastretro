class Retros::ActionReviewsController < ApplicationController
  include RetroAuthorization

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

  def phase_path_for(retro)
    case retro.phase.to_sym
    when :waiting_room then retro_waiting_room_path(retro)
    when :brainstorming then retro_brainstorming_path(retro)
    when :grouping then retro_grouping_path(retro)
    when :voting then retro_voting_path(retro)
    when :discussion then retro_discussion_path(retro)
    when :complete then retro_complete_path(retro)
    else retro_path(retro)
    end
  end
end

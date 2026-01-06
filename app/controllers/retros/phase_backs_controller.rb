class Retros::PhaseBacksController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    @retro.back_phase!
    broadcast_phase_redirect
    redirect_to phase_path_for(@retro)
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def phase_path_for(retro)
    case retro.phase.to_sym
    when :waiting_room then retro_waiting_room_path(retro)
    when :action_review then retro_action_review_path(retro)
    when :brainstorming then retro_brainstorming_path(retro)
    when :grouping then retro_grouping_path(retro)
    when :voting then retro_voting_path(retro)
    when :discussion then retro_discussion_path(retro)
    when :complete then retro_complete_path(retro)
    else retro_path(retro)
    end
  end

  def broadcast_phase_redirect
    redirect_url = phase_path_for(@retro)
    Turbo::StreamsChannel.broadcast_stream_to(
      @retro,
      content: %(<turbo-stream action="redirect" url="#{redirect_url}"></turbo-stream>)
    )
  end
end

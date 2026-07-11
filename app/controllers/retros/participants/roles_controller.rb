class Retros::Participants::RolesController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  before_action :set_retro
  before_action :ensure_retro_admin
  before_action :set_participant

  def update
    if @participant.update(role_params)
      redirect_back fallback_location: phase_path_for(@retro)
    else
      redirect_back fallback_location: phase_path_for(@retro), alert: @participant.errors.full_messages.to_sentence
    end
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def set_participant
      @participant = @retro.participants.find(params[:participant_id])
    end

    def role_params
      { role: params.require(:participant)[:role].presence_in(%w[ admin participant ]) || "participant" }
    end
end

class Retros::Participants::RolesController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  before_action :set_retro
  before_action :ensure_retro_admin
  before_action :set_participant

  def update
    if role_param.nil?
      head :unprocessable_entity
    elsif @retro.with_lock { @participant.update(role: role_param) }
      redirect_back fallback_location: phase_path_for(@retro), status: :see_other
    else
      redirect_back fallback_location: phase_path_for(@retro), status: :see_other, alert: @participant.errors.full_messages.to_sentence
    end
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def set_participant
      @participant = @retro.participants.find(params[:participant_id])
    end

    def role_param
      params.require(:participant)[:role].presence_in(Retro::Participant.roles.keys)
    end
end

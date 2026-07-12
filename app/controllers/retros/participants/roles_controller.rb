class Retros::Participants::RolesController < ApplicationController
  include RetroAuthorization
  include RetroPhaseNavigation

  before_action :set_retro
  before_action :ensure_retro_admin
  before_action :set_participant

  def update
    if role_param.nil?
      head :unprocessable_entity
    elsif update_role
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

    # Serializes role changes per retro and re-checks against fresh data, so a
    # concurrently demoted admin cannot slip a change through with stale state.
    def update_role
      @retro.with_lock do
        @participant.reload
        raise RetroNotFoundError unless @retro.participants.admin.exists?(user: Current.user)

        @participant.update(role: role_param)
      end
    end
end

module RetroAuthorization
  extend ActiveSupport::Concern

  class RetroNotFoundError < StandardError; end

  included do
    rescue_from RetroAuthorization::RetroNotFoundError, with: :handle_retro_not_found
  end

  private

  def ensure_retro_participant
    raise RetroNotFoundError unless @retro.account == Current.account

    # Auto-add account members as participants when they access a retro
    if Current.user.present? && !@retro.participant?(Current.user)
      @retro.add_participant(Current.user)
    end
  end

  def ensure_retro_admin
    raise RetroNotFoundError unless @retro.admin?(Current.user)
  end

  def handle_retro_not_found
    redirect_to retros_path, alert: "Retro not found"
  end
end

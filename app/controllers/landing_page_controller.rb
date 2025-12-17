class LandingPageController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  layout "public"

  before_action :redirect_authenticated_user_to_session_menu

  # Retro count from the Laravel version before migrating to Rails
  LEGACY_RETRO_COUNT = 1124

  def show
    @free_limit = Identity::FREE_FEEDBACK_LIMIT
    @retro_count = Rails.cache.fetch("retro_count", expires_in: 4.hours) do
      Retro.count + LEGACY_RETRO_COUNT
    end
  end

  private
    def redirect_authenticated_user_to_session_menu
      # If user is authenticated but has no account scope, send them to session menu
      if authenticated? && Current.account.blank?
        redirect_to session_menu_url(script_name: nil)
      end
    end
end

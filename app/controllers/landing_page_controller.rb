class LandingPageController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  layout "public"

  before_action :redirect_authenticated_user_to_session_menu

  def show
    @free_limit = Plan.free.feedback_limit
  end

  private
    def redirect_authenticated_user_to_session_menu
      # If user is authenticated but has no account scope, send them to session menu
      if authenticated? && Current.account.blank?
        redirect_to session_menu_url(script_name: nil)
      end
    end
end

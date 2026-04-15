class LandingPageController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  allow_search_engine_indexing
  layout "public"

  before_action :redirect_authenticated_user_to_session_menu

  def show
    @free_limit = Plan.free.retro_limit
    @paid_price = Plan.paid.price_for_display
  rescue Plan::StripePriceUnavailableError
    @paid_price = nil
  end

  private
    def redirect_authenticated_user_to_session_menu
      # If user is authenticated but has no account scope, send them to session menu
      if authenticated? && Current.account.blank?
        redirect_to session_menu_url(script_name: nil)
      end
    end
end

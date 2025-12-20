class AlternativesController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  layout "public"

  before_action :redirect_authenticated_user

  def easyretro
    @free_limit = Plan.free.feedback_limit
  end

  private
    def redirect_authenticated_user
      if authenticated? && Current.account.blank?
        redirect_to session_menu_url(script_name: nil)
      end
    end
end

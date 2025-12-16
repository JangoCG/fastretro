class AdminController < ApplicationController
  disallow_account_scope
  before_action :ensure_staff

  private
    def ensure_staff
      unless Current.identity&.staff?
        redirect_to session_menu_url(script_name: nil), alert: "You don't have access to this area."
      end
    end
end

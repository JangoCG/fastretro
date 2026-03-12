class AdminController < ApplicationController
  disallow_account_scope
  before_action :ensure_staff

  private
    def ensure_staff
      unless Current.identity&.staff?
        redirect_to session_menu_url(script_name: nil), alert: t("flash.no_admin_access")
      end
    end
end

# frozen_string_literal: true

class ShoutoutsController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  allow_search_engine_indexing
  layout "public"

  before_action :redirect_authenticated_user

  def index
  end

  private
    def redirect_authenticated_user
      if authenticated? && Current.account.blank?
        redirect_to session_menu_url(script_name: nil)
      end
    end
end

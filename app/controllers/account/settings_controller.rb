class Account::SettingsController < ApplicationController
  before_action :ensure_admin, only: :update
  before_action :set_account

  def show
    @users = @account.users.active.alphabetically.includes(:identity)
    @free_limit = Plan.free.feedback_limit
    @paid_price = Plan.paid.price_for_display
  rescue Plan::StripePriceUnavailableError => error
    @paid_price = nil
    flash.now[:alert] = error.message
  end

  def update
    @account.update!(account_params)
    redirect_to account_settings_path
  end

  private
    def set_account
      @account = Current.account
    end

    def account_params
      params.expect account: %i[ name ]
    end
end

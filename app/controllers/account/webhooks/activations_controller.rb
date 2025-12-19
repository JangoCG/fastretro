class Account::Webhooks::ActivationsController < ApplicationController
  before_action :ensure_admin

  def create
    webhook = Current.account.webhooks.find(params[:webhook_id])
    webhook.activate
    redirect_to account_webhook_path(webhook), notice: "Webhook reactivated."
  end
end

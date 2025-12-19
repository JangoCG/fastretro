class Account::WebhooksController < ApplicationController
  before_action :ensure_admin
  before_action :set_webhook, except: %i[ index new create ]

  def index
    @webhooks = Current.account.webhooks.ordered
  end

  def show
    @deliveries = @webhook.deliveries.ordered.limit(20)
  end

  def new
    @webhook = Current.account.webhooks.new
  end

  def create
    @webhook = Current.account.webhooks.create!(webhook_params)
    redirect_to account_webhook_path(@webhook), notice: "Webhook created."
  end

  def edit
  end

  def update
    @webhook.update!(webhook_params.except(:url))
    redirect_to account_webhook_path(@webhook), notice: "Webhook updated."
  end

  def destroy
    @webhook.destroy!
    redirect_to account_webhooks_path, notice: "Webhook deleted."
  end

  private
    def set_webhook
      @webhook = Current.account.webhooks.find(params[:id])
    end

    def webhook_params
      params.expect(webhook: [ :name, :url, subscribed_actions: [] ])
    end
end

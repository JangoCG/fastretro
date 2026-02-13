class Account::SubscriptionsController < ApplicationController
  before_action :ensure_admin
  before_action :set_stripe_session, only: :show

  rescue_from Stripe::StripeError, with: :handle_stripe_error

  def show
  end

  def create
    if plan_param.stripe_price_id.blank?
      redirect_to account_settings_path, alert: "Stripe is not configured. Please set the price id environment variable." and return
    end

    checkout_session = Stripe::Checkout::Session.create \
      customer: find_or_create_stripe_customer,
      mode: "subscription",
      line_items: [ { price: plan_param.stripe_price_id, quantity: 1 } ],
      success_url: account_subscription_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: account_subscription_url,
      metadata: { account_id: Current.account.id, plan_key: plan_param.key },
      automatic_tax: { enabled: true },
      tax_id_collection: { enabled: true },
      billing_address_collection: "required",
      customer_update: { address: "auto", name: "auto" }

    redirect_to checkout_session.url, allow_other_host: true
  end

  private
    def plan_param
      @plan_param ||= Plan[params[:plan_key]] || Plan.paid
    end

    def set_stripe_session
      @stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id]) if params[:session_id]
    end

    def ensure_admin
      head :forbidden unless Current.user.admin?
    end

    def find_or_create_stripe_customer
      find_stripe_customer || create_stripe_customer
    end

    def find_stripe_customer
      Stripe::Customer.retrieve(Current.account.subscription.stripe_customer_id) if Current.account.subscription&.stripe_customer_id
    end

    def create_stripe_customer
      Stripe::Customer.create(email: Current.user.identity.email_address, name: Current.account.name, metadata: { account_id: Current.account.id }).tap do |customer|
        Current.account.create_subscription!(stripe_customer_id: customer.id, plan_key: plan_param.key, status: "incomplete")
      end
    end

    def handle_stripe_error(error)
      Rails.logger.error(
        "[billing] Stripe error in Account::SubscriptionsController#create " \
        "request_id=#{Current.request_id} account_id=#{Current.account&.id} " \
        "user_id=#{Current.user&.id} #{error.class}: #{error.message}"
      )
      Rails.logger.error(error.backtrace.first(15).join("\n")) if error.backtrace.present?

      redirect_to account_settings_path, alert: "Something went wrong with the payment provider. Please try again."
    end
end

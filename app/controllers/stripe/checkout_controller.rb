# frozen_string_literal: true

# Handles Stripe Checkout flow for subscriptions.
#
# This controller manages the checkout process using Stripe's prebuilt
# Checkout page. It creates checkout sessions and handles success/cancel redirects.
#
# @see https://docs.stripe.com/billing/quickstart?lang=ruby
# @see https://docs.stripe.com/api/checkout/sessions
#
# @example Routes
#   get "checkout", to: "stripe/checkout#new"
#   post "checkout", to: "stripe/checkout#create"
#   get "checkout/success", to: "stripe/checkout#success"
#   get "checkout/cancel", to: "stripe/checkout#cancel"
#
class Stripe::CheckoutController < ApplicationController
  layout "stripe"
  disallow_account_scope
  before_action :ensure_stripe_customer, only: :create

  # GET /checkout
  # Displays the checkout page with product information.
  # The page contains a form that posts to #create with a lookup_key.
  def new
  end

  # POST /checkout
  # Creates a Stripe Checkout Session and redirects to Stripe's hosted payment page.
  #
  # Uses the price's lookup_key to retrieve the price ID from Stripe.
  # This allows you to change prices in Stripe Dashboard without updating code.
  #
  # @param lookup_key [String] The lookup_key of the price (set in Stripe Dashboard)
  # @return [void] Redirects to Stripe Checkout or back to checkout page on error
  #
  # @see https://docs.stripe.com/api/prices/list
  # @see https://docs.stripe.com/api/checkout/sessions/create
  def create
    # Retrieve the price using its lookup_key.
    # lookup_keys allow you to transfer prices across Stripe accounts
    # and update pricing without changing code.
    prices = Stripe::Price.list(
      lookup_keys: [ params[:lookup_key] ],
      expand: [ "data.product" ]
    )

    # Create a Checkout Session with the price.
    # mode: 'subscription' tells Stripe we expect a recurring plan.
    # Use 'payment' for one-time payments or 'setup' for saving payment methods.
    session = Stripe::Checkout::Session.create({
      customer: Current.identity.stripe_customer_id,
      mode: "subscription",
      line_items: [ {
        quantity: 1,
        price: prices.data[0].id
      } ],
      # {CHECKOUT_SESSION_ID} is a placeholder that Stripe replaces with the actual session ID.
      # This allows you to retrieve the session on the success page.
      success_url: stripe_checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: stripe_checkout_cancel_url
    })

    # Redirect to Stripe's hosted Checkout page.
    # status: :see_other (303) is required for POST -> redirect pattern.
    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::StripeError => e
    flash[:alert] = e.message
    redirect_to stripe_checkout_path
  end

  # GET /checkout/success
  # Displays the success page after a successful checkout.
  # The session_id is passed as a query parameter by Stripe.
  #
  # @param session_id [String] The Checkout Session ID from Stripe
  def success
    @session_id = params[:session_id]
  end

  # GET /checkout/cancel
  # Displays the cancel page when user cancels checkout.
  def cancel
  end

  private

  # Ensures the current user has a Stripe customer ID before checkout.
  # If the background job hasn't completed yet, create the customer synchronously.
  def ensure_stripe_customer
    identity = Current.identity
    return if identity.stripe_customer_id.present?

    customer = Stripe::Customer.create(
      email: identity.email_address,
      metadata: { identity_id: identity.id }
    )
    identity.update!(stripe_customer_id: customer.id)
  end
end

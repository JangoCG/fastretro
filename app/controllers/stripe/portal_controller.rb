# frozen_string_literal: true

# Handles Stripe Customer Portal sessions.
#
# The Customer Portal is a Stripe-hosted page where customers can manage
# their subscriptions, update payment methods, view invoices, and more.
#
# @see https://docs.stripe.com/billing/subscriptions/integrating-customer-portal
# @see https://docs.stripe.com/api/customer_portal
#
# @example Routes
#   post "portal", to: "stripe/portal#create"
#
class Stripe::PortalController < ApplicationController
  layout "stripe"
  disallow_account_scope

  # POST /portal
  # Creates a Billing Portal Session and redirects to Stripe's hosted portal.
  #
  # The portal allows customers to:
  # - View and update their subscription
  # - Update payment methods
  # - View billing history and invoices
  # - Cancel their subscription
  #
  # @note For demonstration purposes, Stripe's example uses the Checkout session
  #   to retrieve the customer ID. In production, you should use the
  #   authenticated user's stripe_customer_id stored in your database.
  #
  # @return [void] Redirects to Stripe Customer Portal
  #
  # @see https://docs.stripe.com/api/customer_portal/sessions/create
  def create
    # Use the authenticated user's stripe_customer_id.
    # Replace Current.identity with your user model (e.g., current_user).
    customer_id = Current.identity.stripe_customer_id

    # This is the URL to which users will be redirected after they're done
    # managing their billing.
    return_url = root_url(script_name: nil)

    session = Stripe::BillingPortal::Session.create({
      customer: customer_id,
      return_url: return_url
    })

    # Redirect to Stripe's hosted Customer Portal.
    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::StripeError => e
    flash[:alert] = e.message
    redirect_to stripe_checkout_path
  end
end

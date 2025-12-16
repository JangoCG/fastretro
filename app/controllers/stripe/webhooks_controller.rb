# frozen_string_literal: true

# Handles incoming Stripe webhook events.
#
# Webhooks notify your application of events that happen in Stripe,
# such as successful payments, subscription changes, and more.
#
# @see https://docs.stripe.com/webhooks
# @see https://docs.stripe.com/billing/subscriptions/webhooks
#
# @example Routes
#   # stripe listen --forward-to localhost:3000/webhook
#   post "webhook", to: "stripe/webhooks#create"
#
# @example Testing with Stripe CLI
#   stripe listen --forward-to localhost:3000/webhook
#   stripe trigger customer.subscription.created
#
class Stripe::WebhooksController < ActionController::Base
  # Skip CSRF verification for webhook endpoints.
  # Stripe signs webhooks with a signature that we verify instead.
  skip_before_action :verify_authenticity_token

  # POST /webhook
  # Receives and processes Stripe webhook events.
  #
  # @return [JSON] Returns {status: "success"} on successful processing
  # @return [void] Returns 400 Bad Request on invalid payload or signature
  def create
    # Replace this endpoint secret with your endpoint's unique secret.
    # If you are testing with the CLI, find the secret by running 'stripe listen'.
    # If you are using an endpoint defined with the API or dashboard, look in your webhook settings
    # at https://dashboard.stripe.com/webhooks
    webhook_secret = ENV["STRIPE_WEBHOOK_SECRET"]
    payload = request.body.read

    if webhook_secret.present?
      # Retrieve the event by verifying the signature using the raw body and secret
      # if webhook signing is configured.
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      rescue JSON::ParserError
        # Invalid payload
        head :bad_request
        return
      rescue Stripe::SignatureVerificationError
        # Invalid signature
        puts "⚠️  Webhook signature verification failed."
        head :bad_request
        return
      end
    else
      begin
        data = JSON.parse(payload, symbolize_names: true)
        event = Stripe::Event.construct_from(data)
      rescue JSON::ParserError
        head :bad_request
        return
      end
    end

    # Get the type of webhook event sent - used to check the status of PaymentIntents.
    handle_event(event)

    render json: { status: "success" }
  end

  private

  # Routes webhook events to appropriate handlers.
  #
  # @param event [Stripe::Event] The webhook event from Stripe
  def handle_event(event)
    case event.type
    when "customer.created"
      # Handle customer created - link Stripe customer to your user.
      handle_customer_created(event.data.object)
    when "customer.subscription.created"
      # Handle subscription created.
      handle_subscription_created(event.data.object)
    when "customer.subscription.updated"
      # Handle subscription updated.
      handle_subscription_updated(event.data.object)
    when "customer.subscription.deleted"
      # Handle subscription canceled automatically based
      # upon your subscription settings. Or if the user cancels it.
      handle_subscription_deleted(event.data.object)
    when "customer.subscription.trial_will_end"
      # Handle subscription trial ending.
      # Send a reminder email to the customer.
      handle_subscription_trial_will_end(event.data.object)
    when "entitlements.active_entitlement_summary.updated"
      # Handle active entitlement summary updated.
      # Use this for feature entitlements.
      handle_entitlement_updated(event.data.object)
    else
      puts "Unhandled event type: #{event.type}"
    end
  end

  # Handles customer.created event.
  # Fallback to link Stripe customer ID if the background job failed.
  # Uses multiple strategies to find the identity for reliability.
  #
  # @param customer [Stripe::Customer] The customer object from Stripe
  def handle_customer_created(customer)
    # 1. Try to find user via Identity ID
    identity_id = customer.metadata&.identity_id
    identity = Identity.find_by(id: identity_id) if identity_id.present?

    # 2. Try to find with stripe_customer_id
    identity ||= Identity.find_by(stripe_customer_id: customer.id)

    # 3. Fallback: with email address
    identity ||= Identity.find_by(email_address: customer.email)

    return unless identity

    # Only link Stripe customer ID if after_create_commit failed
    if identity.stripe_customer_id.blank?
      identity.update(stripe_customer_id: customer.id)
    end
  end

  # Handles customer.subscription.created event.
  #
  # @param subscription [Stripe::Subscription] The subscription object from Stripe
  def handle_subscription_created(subscription)
    puts "Subscription created: #{subscription.id}"
    update_user_subscription(subscription)
  end

  # Handles customer.subscription.updated event.
  #
  # @param subscription [Stripe::Subscription] The subscription object from Stripe
  def handle_subscription_updated(subscription)
    puts "Subscription updated: #{subscription.id}"
    update_user_subscription(subscription)
  end

  # Handles customer.subscription.deleted event.
  #
  # @param subscription [Stripe::Subscription] The subscription object from Stripe
  def handle_subscription_deleted(subscription)
    puts "Subscription canceled: #{subscription.id}"
    update_user_subscription(subscription)
  end

  # Handles customer.subscription.trial_will_end event.
  # Called 3 days before trial ends by default.
  #
  # @param subscription [Stripe::Subscription] The subscription object from Stripe
  def handle_subscription_trial_will_end(subscription)
    puts "Subscription trial will end: #{subscription.id}"
    # TODO: Send reminder email to customer
  end

  # Handles entitlements.active_entitlement_summary.updated event.
  #
  # @param entitlement_summary [Stripe::EntitlementSummary] The entitlement summary from Stripe
  def handle_entitlement_updated(entitlement_summary)
    puts "Active entitlement summary updated: #{entitlement_summary.id}"
    # TODO: Update user's feature access based on entitlements
  end

  # Updates the user's subscription data in the database.
  #
  # @param subscription [Stripe::Subscription] The subscription object from Stripe
  def update_user_subscription(subscription)
    identity = Identity.find_by(stripe_customer_id: subscription.customer)
    return unless identity

    items = subscription.items
    return unless items&.data.present?

    item = items.data.first
    price = item.price

    identity.update(
      plan: price&.lookup_key || price&.id,
      subscription_status: subscription.status,
      subscription_ends_at: item.current_period_end ? Time.zone.at(item.current_period_end) : nil
    )
  end
end

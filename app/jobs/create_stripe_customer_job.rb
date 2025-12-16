# frozen_string_literal: true

class CreateStripeCustomerJob < ApplicationJob
  queue_as :default
  retry_on Stripe::StripeError, wait: :exponentially_longer, attempts: 3

  # If the identity is deleted before the job runs, discard the job
  # rather than raising a deserialization error.
  discard_on ActiveJob::DeserializationError

  def perform(identity)
    Rails.logger.info "[Stripe] Creating customer for ID:#{identity.id} EMAIL:#{identity.email_address}"

    # Idempotency check - skip if already has a Stripe customer
    return if identity.stripe_customer_id.present?

    # Create Stripe customer with metadata for reliable linking
    stripe_customer = Stripe::Customer.create(
      email: identity.email_address,
      metadata: { identity_id: identity.id }
    )

    # Update our database with the Stripe customer ID
    identity.update!(stripe_customer_id: stripe_customer.id)
  end
end

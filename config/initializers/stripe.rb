# frozen_string_literal: true

Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
Stripe.api_version = ENV.fetch("STRIPE_API_VERSION", "2025-03-31.basil")

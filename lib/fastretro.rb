# frozen_string_literal: true

# FastRetro application configuration module.
#
# Provides application-wide settings and feature flags.
#
# @example Check if SaaS mode is enabled
#   FastRetro.saas? # => true or false
#
# @example Enable SaaS mode
#   rake saas:enable
#
# @example Disable SaaS mode
#   rake saas:disable
#
module FastRetro
  class << self
    # Checks if the application is running in SaaS mode.
    #
    # SaaS mode enables:
    # - Usage limits and paywall
    # - Subscription management
    # - Stripe integration
    #
    # @return [Boolean] true if SaaS mode is enabled
    #
    # @example Enable via environment variable
    #   SAAS=true bin/rails server
    #
    # @example Enable via file
    #   touch tmp/saas.txt
    #
    def saas?
      return @saas if defined?(@saas)

      saas_file = File.expand_path("../tmp/saas.txt", __dir__)
      @saas = !!((ENV["SAAS"] || File.exist?(saas_file)) && ENV["SAAS"] != "false")
    end

    # Resets the cached SaaS mode value.
    # Useful for testing.
    def reset_saas!
      remove_instance_variable(:@saas) if defined?(@saas)
    end

    # Sets the SaaS mode value directly.
    # Useful for testing without file system race conditions.
    #
    # @param value [Boolean] whether to enable SaaS mode
    attr_writer :saas

    # Pricing configuration for the subscription plan.
    # Override these values via environment variables in production.
    def pricing
      @pricing ||= {
        plan_name: ENV.fetch("STRIPE_PLAN_NAME", "Fast Retro License"),
        price_display: ENV.fetch("STRIPE_PRICE_DISPLAY", "€9.99 / month"),
        lookup_key: ENV.fetch("STRIPE_LOOKUP_KEY", "standard_monthly")
      }
    end
  end
end

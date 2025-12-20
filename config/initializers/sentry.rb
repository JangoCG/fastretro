# frozen_string_literal: true

# Sentry error tracking configuration.
#
# Only enabled in non-local environments (production, staging) when
# SENTRY_DSN is provided. Can be disabled by setting SKIP_TELEMETRY=true.
#
# Required environment variables:
#   - SENTRY_DSN: Your Sentry project DSN
#
# Optional environment variables:
#   - KAMAL_VERSION: Deployment version for release tracking
#   - SKIP_TELEMETRY: Set to any value to disable Sentry
#
# @see https://docs.sentry.io/platforms/ruby/guides/rails/
#
if !Rails.env.local? && ENV["SKIP_TELEMETRY"].blank? && ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    # DSN from environment variable (NEVER hardcode this)
    config.dsn = ENV["SENTRY_DSN"]

    # Breadcrumbs: log Rails activity and HTTP requests for debugging context
    config.breadcrumbs_logger = %i[active_support_logger http_logger]

    # Privacy: Do NOT send personally identifiable information
    config.send_default_pii = false

    # Release tracking: tag errors with deployment version
    config.release = ENV["KAMAL_VERSION"]

    # Exclude noisy exceptions that aren't actionable
    config.excluded_exceptions += [
      "ActiveRecord::ConcurrentMigrationError"
    ]

    # Rails integration: Subscribe to Rails.error.report
    # This captures errors from retry_on/discard_on with `report: true`
    config.rails.register_error_subscriber = true
  end
end

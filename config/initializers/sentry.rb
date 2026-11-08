require "sentry_sql_redaction"

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
    SentrySqlRedaction.install(config)

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

# Rails edge (actioncable 647ce6769c, 2026-05-28) extracted WebSocket handling
# into ActionCable::Server::Socket, which now calls connection.handle_open /
# handle_close *publicly*. sentry-rails (through 6.7.0 and master as of 2026-08)
# still prepends these onto ActionCable::Connection::Base as `private`, matching
# the old internal calling convention, so the external call raises NoMethodError
# and every WebSocket connection dies. Restore public visibility on Sentry's
# module until sentry-ruby adapts to the refactor.
#
# sentry-rails prepends its module via on_load(:action_cable_connection), which
# fires lazily when ActionCable::Connection::Base first loads. Register our own
# hook so it runs right after Sentry's (on_load callbacks fire in registration
# order); doing it from after_initialize guarantees ours queues after Sentry's.
# Remove once https://github.com/getsentry/sentry-ruby ships a compatible release.
Rails.application.config.after_initialize do
  ActiveSupport.on_load(:action_cable_connection) do
    if defined?(Sentry::Rails::ActionCableExtensions::Connection)
      Sentry::Rails::ActionCableExtensions::Connection.class_eval do
        # Guard per method: a future sentry-rails may rename/remove one, and calling
        # `public` on an undefined method raises NameError — which would break SaaS
        # boot here. Only flip the visibility of methods that actually exist.
        %i[ handle_open handle_close ].each do |method|
          public method if method_defined?(method) || private_method_defined?(method)
        end
      end
    end
  end
end

require "active_support/core_ext/integer/time"
require "json"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # CSP: Allow form submissions to Stripe Checkout and Billing Portal
  config.x.content_security_policy.form_action = "https://checkout.stripe.com https://billing.stripe.com"

  # CSP: Allow analytics scripts (Umami, Cloudflare)
  config.x.content_security_policy.script_src = "https://analytics.cengizg.com https://static.cloudflareinsights.com"
  config.x.content_security_policy.connect_src = "https://analytics.cengizg.com https://cloudflareinsights.com"

  # Email provider Settings
  #
  # SMTP setting can be configured via environment variables.
  # For other configuration options, consult the Action Mailer documentation.
  if smtp_address = ENV["SMTP_ADDRESS"].presence
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: smtp_address,
      port: ENV.fetch("SMTP_PORT", ENV["SMTP_TLS"] == "true" ? "465" : "587").to_i,
      domain: ENV.fetch("SMTP_DOMAIN", nil),
      user_name: ENV.fetch("SMTP_USERNAME", nil),
      password: ENV.fetch("SMTP_PASSWORD", nil),
      authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain"),
      tls: ENV["SMTP_TLS"] == "true",
      openssl_verify_mode: ENV["SMTP_SSL_VERIFY_MODE"]
    }
  end

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT in JSON format so log shipping can reliably extract level/message.
  config.log_tags = [ :request_id ]
  json_logger = ActiveSupport::Logger.new(STDOUT)
  json_logger.formatter = proc do |severity, timestamp, progname, msg|
    message = case msg
    when ::String
      msg
    when ::Exception
      "#{msg.message} (#{msg.class})\n#{Array(msg.backtrace).join("\n")}"
    else
      msg.inspect
    end

    payload = {
      time: timestamp.utc.iso8601(6),
      level: severity.downcase,
      msg: message
    }
    payload[:progname] = progname if progname.present?

    "#{JSON.generate(payload)}\n"
  end
  config.logger = ActiveSupport::TaggedLogging.new(json_logger)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }


  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Active Record Encryption
  config.active_record.encryption.primary_key = ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"]
  config.active_record.encryption.deterministic_key = ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"]
  config.active_record.encryption.key_derivation_salt = ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end

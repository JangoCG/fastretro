# frozen_string_literal: true

# Content Security Policy configuration.
#
# CSP is a security feature that helps prevent XSS attacks by controlling
# which resources the browser is allowed to load.
#
# Configuration via environment variables:
#   CSP_REPORT_URI   - Sentry CSP endpoint for violation reports
#   CSP_REPORT_ONLY  - Set to "true" to report without enforcing
#   DISABLE_CSP      - Set to any value to disable CSP entirely
#
# @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.configure do
  # Report URI for CSP violations (e.g., Sentry CSP endpoint)
  report_uri = ENV["CSP_REPORT_URI"]
  report_only = ENV["CSP_REPORT_ONLY"] == "true"

  # Generate nonces for importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self
    policy.connect_src :self

    # Allow inline styles, data URIs for images (common for user content)
    policy.style_src :self, :unsafe_inline
    policy.img_src :self, "blob:", "data:", "https:"
    policy.font_src :self, "data:"
    policy.media_src :self, "blob:", "data:"
    policy.worker_src :self, "blob:"
    policy.frame_src :self

    # Security-critical: block object embeds and base tag hijacking
    policy.object_src :none
    policy.base_uri :none

    policy.form_action :self
    policy.frame_ancestors :self

    # Send violation reports to Sentry
    policy.report_uri report_uri if report_uri
  end

  # Report-only mode: log violations without blocking
  config.content_security_policy_report_only = report_only
end unless ENV["DISABLE_CSP"]

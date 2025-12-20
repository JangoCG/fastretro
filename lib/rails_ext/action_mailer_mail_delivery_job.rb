# frozen_string_literal: true

# Extends Rails' built-in ActionMailer::MailDeliveryJob with SMTP error handling.
#
# This file lives in lib/rails_ext/ (not app/) because it patches a Rails internal
# class rather than defining application code. Files in this directory are:
#
#   1. Excluded from Rails autoloading (see config/application.rb)
#   2. Manually required via config/initializers/extensions.rb
#
# This separation keeps Rails extensions isolated from application code and ensures
# they load at the correct time during Rails boot (after Rails is loaded, but before
# the application fully initializes).
#
# The SmtpDeliveryErrorHandling concern adds:
#   - Automatic retries for transient network errors (timeouts, DNS failures)
#   - Automatic retries for temporary SMTP errors (4xx codes like "server busy")
#   - Graceful handling of permanent failures (invalid addresses, unknown users)
#
# @see SmtpDeliveryErrorHandling
# @see config/initializers/extensions.rb
#
Rails.application.config.to_prepare do
  ActionMailer::MailDeliveryJob.include SmtpDeliveryErrorHandling
end

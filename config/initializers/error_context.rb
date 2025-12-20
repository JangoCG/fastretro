# frozen_string_literal: true

# Adds user and tenant context to all error reports.
#
# This middleware is lazily evaluated - the context is only computed when an
# error is actually reported, not on every request.
#
# Context added:
#   - identity_id: The logged-in user's global identity ID
#   - user_id: The user's ID within the current account
#   - account_id: The current tenant/account ID
#   - request_id: The unique request ID for correlation
#
# @see Current
# @see config/initializers/sentry.rb
#
Rails.error.add_middleware ->(error, context:, **) do
  context.merge \
    identity_id: Current.identity&.id,
    user_id: Current.user&.id,
    account_id: Current.account&.id,
    request_id: Current.request_id
end

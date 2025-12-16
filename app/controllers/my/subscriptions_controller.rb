# frozen_string_literal: true

# Displays the user's subscription and usage information.
#
# This controller is only accessible in SaaS mode.
# It shows the current feedback usage against the free limit
# and provides links to upgrade or manage billing.
#
# @see FastRetro.saas?
# @see Identity#feedback_limit_reached?
#
class My::SubscriptionsController < ApplicationController
  layout "stripe"
  disallow_account_scope
  before_action :require_saas_mode

  # GET /my/subscription
  # Displays usage stats and subscription status.
  def show
    @identity = Current.identity
    @total_feedbacks = @identity.total_feedbacks_count
    @limit = Identity::FREE_FEEDBACK_LIMIT
    @remaining = @identity.feedbacks_remaining
    @percentage = [ (@total_feedbacks.to_f / @limit * 100).round, 100 ].min
  end

  private

  def require_saas_mode
    unless FastRetro.saas?
      redirect_to root_path, alert: "This page is not available in self-hosted mode."
    end
  end
end

module Feedback::LimitedPublishing
  extend ActiveSupport::Concern

  included do
    before_action :ensure_can_publish_feedbacks, only: %i[ create ]
  end

  private
    def ensure_can_publish_feedbacks
      if Current.account.exceeding_feedback_limit?
        redirect_to account_subscription_path, alert: "You've reached your plan's feedback limit. Please upgrade to continue."
      end
    end
end

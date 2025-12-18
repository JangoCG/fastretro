module Feedback::LimitedCreation
  extend ActiveSupport::Concern

  included do
    # Only limit API requests. We let you create drafts in the app to actually show the banner, no matter the feedback count.
    # We limit feedback publications separately. See +Feedback::LimitedPublishing+.
    before_action :ensure_can_create_feedbacks, only: %i[ create ], if: -> { request.format.json? }
  end

  private
    def ensure_can_create_feedbacks
      head :forbidden if Current.account.exceeding_feedback_limit?
    end
end

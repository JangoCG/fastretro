module Feedback::Statuses
  extend ActiveSupport::Concern

  class LimitReached < StandardError; end

  included do
    enum :status, { drafted: "drafted", published: "published" }
  end

  def publish
    if FastRetro.saas?
      transaction do
        raise LimitReached if retro.account.exceeding_feedback_limit?

        update!(status: :published)
        retro.account.increment!(:feedbacks_count)
      end
    else
      update!(status: :published)
    end
    record_event("feedback.published")
  end
end

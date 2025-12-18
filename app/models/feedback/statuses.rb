module Feedback::Statuses
  extend ActiveSupport::Concern

  class LimitReached < StandardError; end

  included do
    enum :status, { drafted: "drafted", published: "published" }
  end

  def publish
    return update!(status: :published) unless FastRetro.saas?

    transaction do
      raise LimitReached if retro.account.exceeding_feedback_limit?

      update!(status: :published)
      retro.account.increment!(:feedbacks_count)
    end
  end
end

module Feedback::Statuses
  extend ActiveSupport::Concern

  class LimitReached < StandardError; end

  included do
    enum :status, { drafted: "drafted", published: "published" }
  end

  def publish
    return update!(status: :published) unless FastRetro.saas?

    transaction do
      owner = retro.account.owner_identity
      raise LimitReached if owner&.feedback_limit_reached?

      update!(status: :published)
      retro.account.increment!(:feedbacks_count)
    end
  end
end

module Action::Statuses
  extend ActiveSupport::Concern

  included do
    enum :status, { drafted: "drafted", published: "published" }
  end

  def publish
    update!(status: :published)
    record_event("action.published")
  end
end

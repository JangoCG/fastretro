module Action::Statuses
  extend ActiveSupport::Concern

  included do
    enum :status, { drafted: "drafted", published: "published" }
  end

  def publish
    update!(status: :published)
  end
end

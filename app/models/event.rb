class Event < ApplicationRecord
  belongs_to :account
  belongs_to :retro
  belongs_to :creator, class_name: "User", optional: true
  belongs_to :eventable, polymorphic: true

  has_many :webhook_deliveries, class_name: "Webhook::Delivery", dependent: :delete_all

  scope :chronologically, -> { order(created_at: :asc, id: :desc) }

  after_create_commit :dispatch_webhooks

  def action
    super.inquiry
  end

  private
    def dispatch_webhooks
      Event::WebhookDispatchJob.perform_later(self)
    end
end

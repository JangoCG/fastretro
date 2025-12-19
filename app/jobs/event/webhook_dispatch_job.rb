class Event::WebhookDispatchJob < ApplicationJob
  queue_as :webhooks

  def perform(event)
    Webhook.active.triggered_by(event).find_each do |webhook|
      webhook.trigger(event)
    end
  end
end

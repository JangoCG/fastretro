require "test_helper"

class Webhook::DelinquencyTrackerTest < ActiveSupport::TestCase
  test "reset on successful delivery" do
    tracker = webhook_delinquency_trackers(:inactive_tracker)
    delivery = webhook_deliveries(:completed_delivery)

    tracker.record_delivery_of(delivery)

    assert_equal 0, tracker.consecutive_failures_count
    assert_nil tracker.first_failure_at
  end

  test "increment failures on failed delivery" do
    tracker = webhook_delinquency_trackers(:active_tracker)
    delivery = webhook_deliveries(:failed_delivery)

    assert_changes -> { tracker.consecutive_failures_count }, from: 0, to: 1 do
      tracker.record_delivery_of(delivery)
    end

    assert_not_nil tracker.first_failure_at
  end

  test "deactivates webhook when delinquent" do
    webhook = webhooks(:active)
    tracker = webhook.delinquency_tracker

    # Simulate delinquency: 10 failures over more than 1 hour
    tracker.update!(consecutive_failures_count: 9, first_failure_at: 2.hours.ago)

    delivery = webhook_deliveries(:failed_delivery)
    tracker.record_delivery_of(delivery)

    assert_not webhook.reload.active?
  end
end

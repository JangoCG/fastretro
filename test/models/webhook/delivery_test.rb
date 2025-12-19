require "test_helper"

class Webhook::DeliveryTest < ActiveSupport::TestCase
  test "succeeded" do
    delivery = webhook_deliveries(:completed_delivery)
    assert delivery.succeeded?
  end

  test "failed" do
    delivery = webhook_deliveries(:failed_delivery)
    assert delivery.failed?
    assert_not delivery.succeeded?
  end

  test "pending" do
    delivery = webhook_deliveries(:pending_delivery)
    assert delivery.pending?
    assert_not delivery.succeeded?
    assert_not delivery.failed?
  end
end

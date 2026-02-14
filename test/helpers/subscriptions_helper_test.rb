require "test_helper"
require "ostruct"

class SubscriptionsHelperTest < ActionView::TestCase
  include SubscriptionsHelper

  test "subscription_period_end_action shows end date message for cancel at period end" do
    subscription = OpenStruct.new(to_be_canceled?: true, canceled?: false, next_amount_due: 20)

    assert_equal "Your Fast Retro subscription ends on", subscription_period_end_action(subscription)
  end

  test "subscription_period_end_action shows ended message for canceled subscription" do
    subscription = OpenStruct.new(to_be_canceled?: false, canceled?: true, next_amount_due: 20)

    assert_equal "Your Fast Retro subscription ended on", subscription_period_end_action(subscription)
  end

  test "subscription_period_end_action shows next payment amount for active subscription" do
    subscription = OpenStruct.new(to_be_canceled?: false, canceled?: false, next_amount_due: 20)

    assert_equal "Your next payment is <b>€20</b> on", subscription_period_end_action(subscription)
  end
end

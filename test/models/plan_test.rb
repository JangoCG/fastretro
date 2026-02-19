require "test_helper"
require "ostruct"

class PlanTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  teardown do
    Rails.cache.clear
  end

  test "price_for_display returns configured price for free plans" do
    plan = Plan.new(key: :free_custom, name: "Free", price: 0, feedback_limit: 10)

    assert_equal 0, plan.price_for_display
  end

  test "price_for_display raises when paid plan has no stripe price id" do
    plan = Plan.new(key: :custom, name: "Custom", price: 9.99, feedback_limit: Float::INFINITY)

    assert_raises(Plan::StripePriceUnavailableError) { plan.price_for_display }
  end

  test "price_for_display raises when stripe api key is missing" do
    plan = Plan.new(key: :custom, name: "Custom", price: 9.99, feedback_limit: Float::INFINITY, stripe_price_id: "price_test_123")
    Stripe.stubs(:api_key).returns(nil)

    assert_raises(Plan::StripePriceUnavailableError) { plan.price_for_display }
  end

  test "price_for_display returns stripe price and caches it" do
    plan = Plan.new(key: :custom, name: "Custom", price: 9.99, feedback_limit: Float::INFINITY, stripe_price_id: "price_test_123")
    Stripe.stubs(:api_key).returns("sk_test_123")
    Stripe::Price.expects(:retrieve).with("price_test_123").at_least_once.returns(OpenStruct.new(unit_amount: 1599))

    assert_equal BigDecimal("15.99"), plan.price_for_display
    assert_equal BigDecimal("15.99"), plan.price_for_display
  end

  test "price_for_display raises when stripe request fails" do
    plan = Plan.new(key: :custom, name: "Custom", price: 9.99, feedback_limit: Float::INFINITY, stripe_price_id: "price_test_123")
    Stripe.stubs(:api_key).returns("sk_test_123")
    Stripe::Price.stubs(:retrieve).raises(Stripe::AuthenticationError.new("No API key provided"))

    assert_raises(Plan::StripePriceUnavailableError) { plan.price_for_display }
  end
end

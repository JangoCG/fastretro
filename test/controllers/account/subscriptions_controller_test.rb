require "test_helper"
require "ostruct"

class Account::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)  # owner
  end

  test "create redirects to stripe checkout" do
    customer = OpenStruct.new(id: "cus_test_fastretro")
    session = OpenStruct.new(url: "https://checkout.stripe.com/session123")

    # Stub Plan.paid to return a plan with a stripe_price_id
    plan = OpenStruct.new(key: "monthly_v1", stripe_price_id: "price_test123")
    Plan.stubs(:paid).returns(plan)

    Stripe::Customer.stubs(:retrieve).returns(customer)
    Stripe::Customer.stubs(:create).returns(customer)
    Stripe::Checkout::Session.stubs(:create).returns(session)

    post account_subscriptions_path

    assert_redirected_to "https://checkout.stripe.com/session123"
  end

  test "create requires admin or owner" do
    logout_and_sign_in_as users(:two)  # member

    post account_subscriptions_path
    assert_response :forbidden
  end
end

require "test_helper"
require "ostruct"

class Account::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one) # owner
  end

  test "show" do
    get account_subscription_path
    assert_response :success
  end

  test "show with session_id retrieves stripe session" do
    Stripe::Checkout::Session.stubs(:retrieve).with("sess_123").returns(OpenStruct.new(id: "sess_123"))

    get account_subscription_path(session_id: "sess_123")
    assert_response :success
  end

  test "create redirects to stripe checkout" do
    customer = OpenStruct.new(id: "cus_test_37signals")
    checkout_session = OpenStruct.new(url: "https://checkout.stripe.com/session123")

    plan = OpenStruct.new(key: "monthly_v1", stripe_price_id: "price_test123")
    Plan.stubs(:paid).returns(plan)

    Stripe::Customer.stubs(:retrieve).returns(customer)
    Stripe::Customer.stubs(:create).returns(customer)
    Stripe::Checkout::Session.stubs(:create).returns(checkout_session)

    post account_subscription_path

    assert_redirected_to "https://checkout.stripe.com/session123"
  end

  test "create handles stripe errors gracefully" do
    plan = OpenStruct.new(key: "monthly_v1", stripe_price_id: "price_test123")
    Plan.stubs(:paid).returns(plan)

    Stripe::Customer.stubs(:create).raises(Stripe::AuthenticationError.new("No API key provided"))

    post account_subscription_path

    assert_redirected_to account_settings_path
    assert_equal "Something went wrong with the payment provider. Please try again.", flash[:alert]
  end

  test "show requires admin" do
    logout_and_sign_in_as users(:two) # member

    get account_subscription_path
    assert_response :forbidden
  end

  test "create requires admin" do
    logout_and_sign_in_as users(:two) # member

    post account_subscription_path
    assert_response :forbidden
  end
end

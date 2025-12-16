# frozen_string_literal: true

require "test_helper"

class Stripe::CheckoutControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity = identities(:one)
    @identity.update!(stripe_customer_id: "cus_test123")
    sign_in_as(@identity)
  end

  teardown do
    FastRetro.reset_saas!
  end

  test "new renders checkout page" do
    untenanted do
      get stripe_checkout_path
    end

    assert_response :success
  end

  test "new requires authentication" do
    sign_out

    untenanted do
      get stripe_checkout_path
    end

    # Redirects to landing page for unauthenticated users
    assert_redirected_to landing_page_url(script_name: nil)
  end

  test "create redirects to Stripe checkout session" do
    mock_price = mock("price")
    mock_price.stubs(:id).returns("price_123")

    mock_prices = mock("prices")
    mock_prices.stubs(:data).returns([ mock_price ])

    mock_session = mock("session")
    mock_session.stubs(:url).returns("https://checkout.stripe.com/test")

    Stripe::Price.stubs(:list).returns(mock_prices)
    Stripe::Checkout::Session.stubs(:create).returns(mock_session)

    untenanted do
      post stripe_checkout_path, params: { lookup_key: "standard_monthly" }
    end

    assert_redirected_to "https://checkout.stripe.com/test"
  end

  test "create handles Stripe errors gracefully" do
    Stripe::Price.stubs(:list).raises(Stripe::StripeError.new("Test error"))

    untenanted do
      post stripe_checkout_path, params: { lookup_key: "standard_monthly" }
    end

    assert_redirected_to stripe_checkout_url(script_name: nil)
    assert_equal "Test error", flash[:alert]
  end

  test "success renders success page" do
    untenanted do
      get stripe_checkout_success_path, params: { session_id: "cs_test123" }
    end

    assert_response :success
  end

  test "cancel renders cancel page" do
    untenanted do
      get stripe_checkout_cancel_path
    end

    assert_response :success
  end
end

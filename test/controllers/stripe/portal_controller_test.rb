# frozen_string_literal: true

require "test_helper"

class Stripe::PortalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity = identities(:one)
    @identity.update!(stripe_customer_id: "cus_test123")
    sign_in_as(@identity)
  end

  teardown do
    FastRetro.reset_saas!
  end

  test "create redirects to Stripe billing portal" do
    mock_session = mock("session")
    mock_session.stubs(:url).returns("https://billing.stripe.com/test")

    Stripe::BillingPortal::Session.stubs(:create).returns(mock_session)

    untenanted do
      post stripe_portal_path
    end

    assert_redirected_to "https://billing.stripe.com/test"
  end

  test "create handles Stripe errors gracefully" do
    Stripe::BillingPortal::Session.stubs(:create).raises(Stripe::StripeError.new("Portal error"))

    untenanted do
      post stripe_portal_path
    end

    assert_redirected_to stripe_checkout_url(script_name: nil)
    assert_equal "Portal error", flash[:alert]
  end

  test "create requires authentication" do
    sign_out

    untenanted do
      post stripe_portal_path
    end

    # Redirects to landing page for unauthenticated users
    assert_redirected_to landing_page_url(script_name: nil)
  end
end

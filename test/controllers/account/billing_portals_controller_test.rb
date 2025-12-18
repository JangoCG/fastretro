require "test_helper"
require "ostruct"

class Account::BillingPortalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)  # owner
  end

  test "redirects to stripe billing portal" do
    Current.account.create_subscription!(
      plan_key: "monthly_v1",
      status: "active",
      stripe_customer_id: "cus_test123"
    )

    session = OpenStruct.new(url: "https://billing.stripe.com/session123")
    Stripe::BillingPortal::Session.expects(:create)
      .with(customer: "cus_test123", return_url: account_settings_url)
      .returns(session)

    get account_billing_portal_path

    assert_redirected_to "https://billing.stripe.com/session123"
  end

  test "requires admin or owner" do
    logout_and_sign_in_as users(:two)  # member

    get account_billing_portal_path

    assert_response :forbidden
  end
end

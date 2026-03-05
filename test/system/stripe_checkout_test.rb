require "application_system_test_case"

class StripeCheckoutTest < ApplicationSystemTestCase
  driven_by :chrome_headless, screen_size: [ 1200, 1000 ]

  setup do
    @original_saas = FastRetro.saas?
    FastRetro.saas = true
  end

  teardown do
    FastRetro.saas = @original_saas
  end

  test "owner can open stripe checkout from subscription settings" do
    skip "Stripe test checkout is not configured" unless stripe_checkout_configured?

    sign_in_as users(:one)
    visit account_settings_path

    assert_selector "#subscription"

    within "#subscription" do
      checkout_form = find("#stripe-checkout-form")
      submit = checkout_form.find("#stripe-checkout-button", visible: :all)
      execute_script("arguments[0].scrollIntoView({block: 'center'});", submit)
      submit.click
    end

    assert wait_for_checkout_page, "Stripe checkout page was not reachable (stuck on: #{safe_current_url})"
  end

  private
    def sign_in_as(user)
      visit session_transfer_url(user.identity.transfer_id, script_name: nil)
      assert_selector "h1", text: "YOUR RETROS"
    end

    def stripe_checkout_configured?
      ENV["STRIPE_SECRET_KEY"].present? && ENV["STRIPE_MONTHLY_V1_PRICE_ID"].present?
    end

    def wait_for_checkout_page(timeout: 30)
      deadline = Time.now + timeout
      while Time.now < deadline
        begin
          return true if URI.parse(current_url).host == "checkout.stripe.com"
        rescue URI::InvalidURIError
        end

        sleep 0.25
      end

      false
    end

    def safe_current_url
      current_url
    rescue StandardError
      "unavailable"
    end
end

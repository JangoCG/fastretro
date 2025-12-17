# frozen_string_literal: true

require "test_helper"

class My::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity = identities(:one)
    sign_in_as(@identity)
  end

  teardown do
    FastRetro.reset_saas!
  end

  test "show renders subscription page in saas mode" do
    FastRetro.saas = true

    untenanted do
      get my_subscription_path
    end

    assert_response :success
  end

  test "show redirects to root in self-hosted mode" do
    FastRetro.saas = false

    untenanted do
      get my_subscription_path
    end

    assert_redirected_to root_url(script_name: nil)
    assert_equal "This page is not available in self-hosted mode.", flash[:alert]
  end

  test "show requires authentication" do
    FastRetro.saas = true
    sign_out

    untenanted do
      get my_subscription_path
    end

    # Redirects to landing page for unauthenticated users
    assert_redirected_to root_url(script_name: nil)
  end

  test "show displays correct usage stats for free user" do
    FastRetro.saas = true
    @identity.update!(subscription_ends_at: nil)
    accounts(:one).update!(feedbacks_count: 2)

    untenanted do
      get my_subscription_path
    end

    assert_response :success
    assert_select "span", text: "2"
  end

  test "show displays active subscription status" do
    FastRetro.saas = true
    @identity.update!(
      subscription_ends_at: 1.month.from_now,
      plan: "pro_monthly"
    )

    untenanted do
      get my_subscription_path
    end

    assert_response :success
    assert_select "span", text: "Active"
  end
end

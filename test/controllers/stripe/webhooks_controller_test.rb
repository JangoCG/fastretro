# frozen_string_literal: true

require "test_helper"

class Stripe::WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity = identities(:one)
    @identity.update!(stripe_customer_id: "cus_test123")

    # Clear webhook secret so tests can run without signature verification
    # (signature verification is tested explicitly in specific tests)
    @original_webhook_secret = ENV["STRIPE_WEBHOOK_SECRET"]
    ENV["STRIPE_WEBHOOK_SECRET"] = nil
  end

  teardown do
    ENV["STRIPE_WEBHOOK_SECRET"] = @original_webhook_secret
    FastRetro.reset_saas!
  end

  test "rejects requests with invalid signature when webhook secret is configured" do
    # Controller reads from ENV["STRIPE_WEBHOOK_SECRET"]
    with_env("STRIPE_WEBHOOK_SECRET" => "whsec_test") do
      post stripe_webhooks_path,
        params: { type: "customer.created" }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "HTTP_STRIPE_SIGNATURE" => "invalid_signature"
        }

      assert_response :bad_request
    end
  end

  test "rejects requests with invalid JSON" do
    # No webhook secret = skip signature verification, but still validate JSON
    post stripe_webhooks_path,
      params: "not valid json",
      headers: { "Content-Type" => "application/json" }

    assert_response :bad_request
  end

  test "handles customer.created event" do
    # No webhook secret configured = skip signature verification

    new_identity = Identity.create!(email_address: "stripe-test@example.com")

    payload = {
      type: "customer.created",
      data: {
        object: {
          id: "cus_new123",
          email: "stripe-test@example.com",
          object: "customer"
        }
      }
    }

    post stripe_webhooks_path,
      params: payload.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
    assert_equal "cus_new123", new_identity.reload.stripe_customer_id
  end

  test "handles customer.subscription.created event" do
    payload = build_subscription_payload("customer.subscription.created", "active")

    post stripe_webhooks_path,
      params: payload.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
    @identity.reload
    assert_equal "active", @identity.subscription_status
    assert_equal "pro_monthly", @identity.plan
  end

  test "handles customer.subscription.updated event" do
    payload = build_subscription_payload("customer.subscription.updated", "past_due")

    post stripe_webhooks_path,
      params: payload.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
    assert_equal "past_due", @identity.reload.subscription_status
  end

  test "handles customer.subscription.deleted event" do
    @identity.update!(subscription_status: "active")

    payload = build_subscription_payload("customer.subscription.deleted", "canceled")

    post stripe_webhooks_path,
      params: payload.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
    assert_equal "canceled", @identity.reload.subscription_status
  end

  test "ignores events for unknown customers" do
    payload = {
      type: "customer.subscription.created",
      data: {
        object: {
          id: "sub_unknown",
          customer: "cus_unknown",
          status: "active",
          items: {
            data: [ {
              price: { id: "price_123", lookup_key: "pro_monthly" },
              current_period_end: 1.month.from_now.to_i
            } ]
          }
        }
      }
    }

    post stripe_webhooks_path,
      params: payload.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
  end

  test "handles unrecognized event types gracefully" do
    payload = {
      type: "some.unknown.event",
      data: { object: { id: "obj_123" } }
    }

    post stripe_webhooks_path,
      params: payload.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :success
  end

  private

  def build_subscription_payload(event_type, status)
    {
      type: event_type,
      data: {
        object: {
          id: "sub_test123",
          customer: @identity.stripe_customer_id,
          status: status,
          items: {
            data: [ {
              price: { id: "price_123", lookup_key: "pro_monthly" },
              current_period_end: 1.month.from_now.to_i
            } ]
          }
        }
      }
    }
  end
end

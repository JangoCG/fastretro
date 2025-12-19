require "test_helper"

class WebhookTest < ActiveSupport::TestCase
  test "create" do
    webhook = Webhook.create!(name: "Test", url: "https://example.com/webhook", account: accounts(:one))
    assert webhook.persisted?
    assert webhook.active?
    assert webhook.signing_secret.present?
    assert webhook.delinquency_tracker.present?
  end

  test "validates the url" do
    webhook = Webhook.new(name: "Test", account: accounts(:one))
    assert_not webhook.valid?
    assert_includes webhook.errors[:url], "is not a valid URL"

    webhook = Webhook.new(name: "Test", account: accounts(:one), url: "not a url")
    assert_not webhook.valid?
    assert_includes webhook.errors[:url], "is not a valid URL"

    webhook = Webhook.new(name: "Test", account: accounts(:one), url: "gopher://example.com/webhook")
    assert_not webhook.valid?
    assert_includes webhook.errors[:url], "must use http or https"

    webhook = Webhook.new(name: "Test", account: accounts(:one), url: "http://example.com/webhook")
    assert webhook.valid?

    webhook = Webhook.new(name: "Test", account: accounts(:one), url: "https://example.com/webhook")
    assert webhook.valid?
  end

  test "deactivate" do
    webhook = webhooks(:active)

    assert_changes -> { webhook.active? }, from: true, to: false do
      webhook.deactivate
    end
  end

  test "activate" do
    webhook = webhooks(:inactive)

    assert_changes -> { webhook.active? }, from: false, to: true do
      webhook.activate
    end
  end

  test "normalizes subscribed_actions" do
    webhook = Webhook.new(
      name: "Test",
      account: accounts(:one),
      url: "https://example.com/webhook",
      subscribed_actions: [ "retro.created", "invalid.action", "retro.completed" ]
    )
    assert_equal %w[ retro.created retro.completed ], webhook.subscribed_actions
  end

  test "triggered_by_action scope" do
    webhook = webhooks(:active)
    assert_includes Webhook.triggered_by_action("retro.created"), webhook
    assert_not_includes Webhook.triggered_by_action("action.completed"), webhook
  end
end

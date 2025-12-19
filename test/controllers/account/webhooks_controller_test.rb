require "test_helper"

class Account::WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @webhook = webhooks(:active)
    sign_in_as :admin
  end

  test "index lists webhooks" do
    get "#{account_path_prefix(@account)}/account/webhooks"

    assert_response :success
    assert_in_body @webhook.name
  end

  test "show displays webhook details" do
    get "#{account_path_prefix(@account)}/account/webhooks/#{@webhook.id}"

    assert_response :success
    assert_in_body @webhook.name
    assert_in_body @webhook.signing_secret
  end

  test "new renders form" do
    get "#{account_path_prefix(@account)}/account/webhooks/new"

    assert_response :success
  end

  test "create creates webhook" do
    assert_difference "Webhook.count", 1 do
      post "#{account_path_prefix(@account)}/account/webhooks", params: {
        webhook: {
          name: "New Webhook",
          url: "https://example.com/new-webhook",
          subscribed_actions: [ "retro.created", "retro.completed" ]
        }
      }
    end

    assert_redirected_to account_webhook_path(Webhook.last)
    assert_equal "New Webhook", Webhook.last.name
  end

  test "edit renders form" do
    get "#{account_path_prefix(@account)}/account/webhooks/#{@webhook.id}/edit"

    assert_response :success
    assert_in_body @webhook.name
  end

  test "update updates webhook" do
    patch "#{account_path_prefix(@account)}/account/webhooks/#{@webhook.id}", params: {
      webhook: { name: "Updated Name" }
    }

    assert_redirected_to account_webhook_path(@webhook)
    assert_equal "Updated Name", @webhook.reload.name
  end

  test "update does not change url" do
    original_url = @webhook.url
    patch "#{account_path_prefix(@account)}/account/webhooks/#{@webhook.id}", params: {
      webhook: { url: "https://hacked.com/webhook" }
    }

    assert_redirected_to account_webhook_path(@webhook)
    assert_equal original_url, @webhook.reload.url
  end

  test "destroy deletes webhook" do
    assert_difference "Webhook.count", -1 do
      delete "#{account_path_prefix(@account)}/account/webhooks/#{@webhook.id}"
    end

    assert_redirected_to account_webhooks_path
  end

  test "requires admin role" do
    logout_and_sign_in_as :two  # member, not admin

    get "#{account_path_prefix(@account)}/account/webhooks"

    assert_response :forbidden
  end
end

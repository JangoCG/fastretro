require "test_helper"

class Account::Webhooks::ActivationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @inactive_webhook = webhooks(:inactive)
    sign_in_as :admin
  end

  test "create activates webhook" do
    assert_not @inactive_webhook.active?

    post "#{account_path_prefix(@account)}/account/webhooks/#{@inactive_webhook.id}/activation"

    assert_redirected_to account_webhook_path(@inactive_webhook)
    assert @inactive_webhook.reload.active?
  end

  test "requires admin role" do
    logout_and_sign_in_as :two  # member, not admin

    post "#{account_path_prefix(@account)}/account/webhooks/#{@inactive_webhook.id}/activation"

    assert_response :forbidden
    assert_not @inactive_webhook.reload.active?
  end
end

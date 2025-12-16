require "test_helper"

class Account::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @other_account = accounts(:two)
    sign_in_as :admin
  end

  CROSS_ACCOUNT_ALERT = "Retro not found. Either it really does not exist or you are not part of that account"

  # === NORMAL ACCESS TESTS ===

  test "show displays account settings" do
    get "#{account_path_prefix(@account)}/account/settings"

    assert_response :success
    assert_in_body @account.name
  end

  test "update changes account name for admin" do
    patch "#{account_path_prefix(@account)}/account/settings", params: { account: { name: "Updated Name" } }

    assert_redirected_to account_settings_path
    assert_equal "Updated Name", @account.reload.name
  end

  test "update requires admin role" do
    logout_and_sign_in_as :two  # member, not admin

    patch "#{account_path_prefix(@account)}/account/settings", params: { account: { name: "Hacked Name" } }

    assert_response :forbidden
    assert_equal "Test Account", @account.reload.name
  end

  # === CROSS-ACCOUNT ACCESS TESTS ===

  test "cross-account access to show redirects with alert" do
    get "#{account_path_prefix(@other_account)}/account/settings"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to update redirects with alert" do
    original_name = @other_account.name

    patch "#{account_path_prefix(@other_account)}/account/settings", params: { account: { name: "Hacked Name" } }

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
    assert_equal original_name, @other_account.reload.name, "Account name should not be changed"
  end

  test "user from other account cannot view settings via URL manipulation" do
    logout_and_sign_in_as :other

    get "#{account_path_prefix(@account)}/account/settings"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "user from other account cannot update settings via URL manipulation" do
    logout_and_sign_in_as :other
    original_name = @account.name

    patch "#{account_path_prefix(@account)}/account/settings", params: { account: { name: "Hacked Name" } }

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
    assert_equal original_name, @account.reload.name, "Account name should not be changed"
  end
end

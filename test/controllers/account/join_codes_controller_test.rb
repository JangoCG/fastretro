require "test_helper"

class Account::JoinCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @other_account = accounts(:two)
    @join_code = account_join_codes(:one)
    @other_join_code = account_join_codes(:two)
    sign_in_as :admin
  end

  CROSS_ACCOUNT_ALERT = "Retro not found. Either it really does not exist or you are not part of that account"

  # === NORMAL ACCESS TESTS ===

  test "show displays join code" do
    get "#{account_path_prefix(@account)}/account/join_code"

    assert_response :success
    assert_in_body @join_code.code
  end

  test "edit displays join code form" do
    get "#{account_path_prefix(@account)}/account/join_code/edit"

    assert_response :success
  end

  test "update changes join code usage limit for admin" do
    patch "#{account_path_prefix(@account)}/account/join_code", params: { account_join_code: { usage_limit: 50 } }

    assert_redirected_to account_join_code_path
    assert_equal 50, @join_code.reload.usage_limit
  end

  test "update requires admin role" do
    logout_and_sign_in_as :two  # member, not admin
    original_limit = @join_code.usage_limit

    patch "#{account_path_prefix(@account)}/account/join_code", params: { account_join_code: { usage_limit: 999 } }

    assert_response :forbidden
    assert_equal original_limit, @join_code.reload.usage_limit
  end

  test "destroy resets join code for admin" do
    original_code = @join_code.code

    delete "#{account_path_prefix(@account)}/account/join_code"

    assert_redirected_to account_join_code_path
    assert_not_equal original_code, @join_code.reload.code, "Join code should be reset"
    assert_equal 0, @join_code.usage_count, "Usage count should be reset"
  end

  test "destroy requires admin role" do
    logout_and_sign_in_as :two  # member, not admin
    original_code = @join_code.code

    delete "#{account_path_prefix(@account)}/account/join_code"

    assert_response :forbidden
    assert_equal original_code, @join_code.reload.code, "Join code should not be reset"
  end

  # === CROSS-ACCOUNT ACCESS TESTS ===

  test "cross-account access to show redirects with alert" do
    get "#{account_path_prefix(@other_account)}/account/join_code"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to edit redirects with alert" do
    get "#{account_path_prefix(@other_account)}/account/join_code/edit"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to update redirects with alert" do
    original_limit = @other_join_code.usage_limit

    patch "#{account_path_prefix(@other_account)}/account/join_code", params: { account_join_code: { usage_limit: 999 } }

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
    assert_equal original_limit, @other_join_code.reload.usage_limit, "Usage limit should not be changed"
  end

  test "cross-account access to destroy redirects with alert" do
    original_code = @other_join_code.code

    delete "#{account_path_prefix(@other_account)}/account/join_code"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
    assert_equal original_code, @other_join_code.reload.code, "Join code should not be reset"
  end

  test "user from other account cannot view join code via URL manipulation" do
    logout_and_sign_in_as :other

    get "#{account_path_prefix(@account)}/account/join_code"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "user from other account cannot edit join code via URL manipulation" do
    logout_and_sign_in_as :other

    get "#{account_path_prefix(@account)}/account/join_code/edit"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "user from other account cannot update join code via URL manipulation" do
    logout_and_sign_in_as :other
    original_limit = @join_code.usage_limit

    patch "#{account_path_prefix(@account)}/account/join_code", params: { account_join_code: { usage_limit: 999 } }

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
    assert_equal original_limit, @join_code.reload.usage_limit, "Usage limit should not be changed"
  end

  test "user from other account cannot destroy join code via URL manipulation" do
    logout_and_sign_in_as :other
    original_code = @join_code.code

    delete "#{account_path_prefix(@account)}/account/join_code"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
    assert_equal original_code, @join_code.reload.code, "Join code should not be reset"
  end
end

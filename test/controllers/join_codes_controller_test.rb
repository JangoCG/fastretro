require "test_helper"

class JoinCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @join_code = account_join_codes(:one)
  end

  test "new" do
    get join_path(code: @join_code.code, script_name: @account.slug)

    assert_response :success
    assert_in_body "Test Account"
  end

  test "new with an invalid code" do
    get join_path(code: "INVALID-CODE", script_name: @account.slug)

    assert_response :not_found
  end

  test "new with an inactive code" do
    @join_code.update!(usage_count: @join_code.usage_limit)

    get join_path(code: @join_code.code, script_name: @account.slug)

    assert_response :gone
  end

  test "create" do
    assert_difference -> { Identity.count }, 1 do
      assert_difference -> { User.count }, 1 do
        post join_path(code: @join_code.code, script_name: @account.slug), params: { email_address: "new_user@example.com" }
      end
    end

    assert_redirected_to session_magic_link_url(script_name: nil)
    assert_equal new_users_verification_url(script_name: @account.slug), session[:return_to_after_authenticating]
  end

  test "create for existing identity" do
    identity = identities(:two)
    sign_in_as :two

    assert identity.users.exists?(account: @account), "Two should be a member of account one for this test"
    assert identity.users.find_by!(account: @account).setup?, "Two's user should be setup for this test"

    assert_no_difference -> { Identity.count } do
      assert_no_difference -> { User.count } do
        post join_path(code: @join_code.code, script_name: @account.slug), params: { email_address: identity.email_address }
      end
    end

    assert_redirected_to landing_url(script_name: @account.slug)
  end

  test "create for signed-in identity without a user in the account redirects to verification" do
    identity = identities(:other)
    sign_in_as :other

    assert_not identity.users.exists?(account: @account), "Other should not be a member of account one for this test"

    assert_no_difference -> { Identity.count } do
      assert_difference -> { User.count }, 1 do
        post join_path(code: @join_code.code, script_name: @account.slug), params: { email_address: identity.email_address }
      end
    end

    assert_redirected_to new_users_verification_url(script_name: @account.slug)
  end

  test "create for different identity terminates existing session" do
    sign_in_as :admin

    assert_difference -> { Identity.count }, 1 do
      assert_difference -> { User.count }, 1 do
        post join_path(code: @join_code.code, script_name: @account.slug), params: { email_address: "new_user@example.com" }
      end
    end

    assert_redirected_to session_magic_link_url(script_name: nil)
    assert_not_predicate cookies[:session_token], :present?
  end

  test "create with invalid email address" do
    without_action_dispatch_exception_handling do
      assert_no_difference -> { Identity.count } do
        assert_no_difference -> { User.count } do
          post join_path(code: @join_code.code, script_name: @account.slug), params: { email_address: "not-a-valid-email" }
        end
      end
      assert_response :unprocessable_entity
    end
  end
end

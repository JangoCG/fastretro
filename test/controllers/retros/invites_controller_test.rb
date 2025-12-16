require "test_helper"

class Retros::InvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @join_code = account_join_codes(:one)
    @retro = retros(:one)
  end

  # === SHOW (GET) TESTS ===

  test "show displays invite form for unauthenticated user" do
    get retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil)

    assert_response :success
    assert_in_body @retro.name
    assert_in_body @account.name
    assert_in_body "JOIN RETRO"
  end

  test "show with invalid join code redirects with alert" do
    get retro_invite_path(code: "INVALID-CODE", retro_id: @retro.id, script_name: nil)

    assert_redirected_to new_session_path(script_name: nil)
    assert_equal "Invalid invite link.", flash[:alert]
  end

  test "show with inactive join code redirects with alert" do
    @join_code.update!(usage_count: @join_code.usage_limit)

    get retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil)

    assert_redirected_to new_session_path(script_name: nil)
    assert_equal "This invite link has expired.", flash[:alert]
  end

  test "show with invalid retro id redirects with alert" do
    get retro_invite_path(code: @join_code.code, retro_id: 99999, script_name: nil)

    assert_redirected_to new_session_path(script_name: nil)
    assert_equal "Retro not found.", flash[:alert]
  end

  test "show redirects authenticated member directly to retro" do
    sign_in_as :two

    get retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil)

    assert_redirected_to retro_path(@retro, script_name: @account.slug)
  end

  test "show auto-joins authenticated non-member and redirects to retro" do
    sign_in_as :other
    identity = identities(:other)

    assert_not identity.users.exists?(account: @account), "Other should not be a member for this test"

    assert_difference -> { User.count }, 1 do
      get retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil)
    end

    assert_redirected_to retro_path(@retro, script_name: @account.slug)
    assert identity.users.exists?(account: @account), "Other should now be a member"
    assert_equal "Welcome! You've joined #{@account.name}.", flash[:notice]
  end

  # === CREATE (POST) TESTS ===

  test "create for new user creates identity, joins account, and sends magic link" do
    assert_difference -> { Identity.count }, 1 do
      assert_difference -> { User.count }, 1 do
        post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
             params: { email_address: "new_invitee@example.com" }
      end
    end

    assert_redirected_to session_magic_link_url(script_name: nil)

    new_identity = Identity.find_by(email_address: "new_invitee@example.com")
    assert new_identity.users.exists?(account: @account), "New user should be added to account"

    # Verify return_to is set to the retro
    assert_equal retro_url(@retro, script_name: @account.slug), session[:return_to_after_authenticating]
  end

  test "create for existing identity who is already a member redirects to retro" do
    identity = identities(:two)
    sign_in_as :two

    assert identity.users.exists?(account: @account), "Two should be a member for this test"

    assert_no_difference -> { Identity.count } do
      assert_no_difference -> { User.count } do
        post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
             params: { email_address: identity.email_address }
      end
    end

    assert_redirected_to retro_path(@retro, script_name: @account.slug)
  end

  test "create for signed-in identity without account membership joins and redirects" do
    identity = identities(:other)
    sign_in_as :other

    assert_not identity.users.exists?(account: @account), "Other should not be a member for this test"

    assert_no_difference -> { Identity.count } do
      assert_difference -> { User.count }, 1 do
        post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
             params: { email_address: identity.email_address }
      end
    end

    # User needs verification since they just joined
    assert_redirected_to new_users_verification_url(script_name: @account.slug)
  end

  test "create for different identity terminates existing session" do
    sign_in_as :admin

    assert_difference -> { Identity.count }, 1 do
      assert_difference -> { User.count }, 1 do
        post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
             params: { email_address: "different_user@example.com" }
      end
    end

    assert_redirected_to session_magic_link_url(script_name: nil)
    assert_not_predicate cookies[:session_token], :present?
  end

  test "create with invalid email address returns unprocessable entity" do
    without_action_dispatch_exception_handling do
      assert_no_difference -> { Identity.count } do
        assert_no_difference -> { User.count } do
          post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
               params: { email_address: "not-a-valid-email" }
        end
      end
      assert_response :unprocessable_entity
    end
  end

  test "create with invalid join code redirects with alert" do
    post retro_invite_path(code: "INVALID-CODE", retro_id: @retro.id, script_name: nil),
         params: { email_address: "test@example.com" }

    assert_redirected_to new_session_path(script_name: nil)
    assert_equal "Invalid invite link.", flash[:alert]
  end

  test "create with inactive join code redirects with alert" do
    @join_code.update!(usage_count: @join_code.usage_limit)

    post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
         params: { email_address: "test@example.com" }

    assert_redirected_to new_session_path(script_name: nil)
    assert_equal "This invite link has expired.", flash[:alert]
  end

  test "create increments join code usage count" do
    initial_count = @join_code.usage_count

    post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
         params: { email_address: "new_user@example.com" }

    @join_code.reload
    assert_equal initial_count + 1, @join_code.usage_count
  end

  test "create adds user as retro participant" do
    post retro_invite_path(code: @join_code.code, retro_id: @retro.id, script_name: nil),
         params: { email_address: "participant@example.com" }

    new_identity = Identity.find_by(email_address: "participant@example.com")
    new_user = new_identity.users.find_by(account: @account)

    assert @retro.participant?(new_user), "New user should be added as retro participant"
  end
end

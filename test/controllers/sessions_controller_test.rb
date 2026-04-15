require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    untenanted do
      get new_session_path
    end

    assert_response :success
  end

  test "new redirects authenticated users" do
    sign_in_as :admin

    untenanted do
      get new_session_path
      assert_redirected_to session_menu_url(script_name: nil)
    end
  end

  test "create" do
    identity = identities(:admin)

    untenanted do
      assert_difference -> { MagicLink.count }, 1 do
        post session_path, params: { email_address: identity.email_address }
      end

      assert_redirected_to session_magic_link_path
      assert_nil flash[:magic_link_code]
    end
  end

  test "create for a new user" do
    untenanted do
      assert_difference -> { MagicLink.count }, +1 do
        assert_difference -> { Identity.count }, +1 do
          post session_path,
            params: { email_address: "nonexistent-#{SecureRandom.hex(6)}@example.com" }
        end
      end

      assert_redirected_to session_magic_link_path
      assert MagicLink.last.for_sign_up?
    end
  end

  test "create with invalid email address" do
    without_action_dispatch_exception_handling do
      untenanted do
        assert_no_difference -> { Identity.count } do
          post session_path, params: { email_address: "not-a-valid-email" }
        end

        assert_response :unprocessable_entity
      end
    end
  end

  test "create with unknown email and signups closed uses fake magic link flow" do
    with_multi_tenant_mode(false) do
      # With multi_tenant off and accounts existing, accepting_signups? returns false
      untenanted do
        assert_no_difference -> { MagicLink.count } do
          assert_no_difference -> { Identity.count } do
            post session_path, params: { email_address: "unknown-#{SecureRandom.hex(6)}@example.com" }
          end
        end

        assert_redirected_to session_magic_link_path
        assert cookies[:pending_authentication_token].present?,
          "Fake flow should set pending token cookie (same as real flow)"
      end
    end
  end

  test "create sets pending authentication token cookie" do
    identity = identities(:admin)

    untenanted do
      post session_path, params: { email_address: identity.email_address }

      assert_redirected_to session_magic_link_path
      assert cookies[:pending_authentication_token].present?,
        "Should set pending authentication token cookie"
    end
  end

  test "destroy" do
    sign_in_as :admin

    untenanted do
      delete session_path

      assert_redirected_to root_path
      assert_not cookies[:session_token].present?
    end
  end
end

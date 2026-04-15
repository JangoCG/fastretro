require "test_helper"

class Sessions::MagicLinksControllerTest < ActionDispatch::IntegrationTest
  test "show redirects when no pending authentication token" do
    untenanted do
      get session_magic_link_url

      assert_response :redirect
      assert_redirected_to new_session_path
    end
  end

  test "create with valid sign in code" do
    identity = identities(:admin)
    magic_link = MagicLink.create!(identity: identity)

    untenanted do
      post session_path, params: { email_address: identity.email_address }
      post session_magic_link_url, params: { code: magic_link.code }

      assert_response :redirect
      assert cookies[:session_token].present?
      assert_redirected_to session_menu_path, "Should redirect to after authentication path"
      assert_not MagicLink.exists?(magic_link.id), "The magic link should be consumed"
      assert cookies[:pending_authentication_token].blank?, "Pending token should be cleared after sign in"
    end
  end

  test "create with sign up code" do
    identity = identities(:admin)
    magic_link = MagicLink.create!(identity: identity, purpose: :sign_up)

    untenanted do
      post session_path, params: { email_address: identity.email_address }
      post session_magic_link_url, params: { code: magic_link.code }

      assert_response :redirect
      assert cookies[:session_token].present?
      assert_redirected_to new_signup_completion_path, "Should redirect to signup completion"
      assert_not MagicLink.exists?(magic_link.id), "The magic link should be consumed"
    end
  end

  test "create with invalid code" do
    identity = identities(:admin)
    magic_link = MagicLink.create!(identity: identity)

    untenanted do
      post session_path, params: { email_address: identity.email_address }
      post session_magic_link_url, params: { code: "INVALID" }
    end

    assert_response :redirect, "Invalid code should redirect"

    expired_link = MagicLink.create!(identity: identity)
    expired_link.update_column(:expires_at, 1.hour.ago)

    untenanted do
      post session_path, params: { email_address: identity.email_address }
      post session_magic_link_url, params: { code: expired_link.code }
    end

    assert_response :redirect, "Expired magic link should redirect"
    assert MagicLink.exists?(expired_link.id), "Expired magic link should not be consumed"
  end

  test "create with email mismatch rejects and clears pending token" do
    identity_a = identities(:admin)
    identity_b = identities(:two)
    magic_link = MagicLink.create!(identity: identity_b)

    untenanted do
      # Set up pending token for identity A
      post session_path, params: { email_address: identity_a.email_address }
      assert cookies[:pending_authentication_token].present?, "Pending token should be set"

      # Try to use identity B's code
      post session_magic_link_url, params: { code: magic_link.code }

      assert_response :redirect
      assert_redirected_to new_session_path
      assert_nil cookies[:session_token], "Should not create session on mismatch"
      assert cookies[:pending_authentication_token].blank?, "Pending token should be cleared on mismatch"
    end
  end

  test "resend sends new magic link using email from cookie" do
    identity = identities(:admin)

    untenanted do
      post session_path, params: { email_address: identity.email_address }
      assert cookies[:pending_authentication_token].present?

      assert_difference -> { MagicLink.count }, 1 do
        post resend_session_magic_link_url
      end

      assert_response :redirect
      assert_redirected_to session_magic_link_path
    end
  end

  test "pending authentication token expires with magic link" do
    identity = identities(:admin)

    untenanted do
      post session_path, params: { email_address: identity.email_address }

      # The cookie is set with the magic link's expiration time
      assert cookies[:pending_authentication_token].present?
    end
  end
end

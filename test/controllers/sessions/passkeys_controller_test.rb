require "test_helper"

class Sessions::PasskeysControllerTest < ActionDispatch::IntegrationTest
  include WebauthnTestHelper

  setup do
    @identity = identities(:one)

    @credential = @identity.passkeys.create!(
      name: "Test Passkey",
      credential_id: Base64.urlsafe_encode64(SecureRandom.random_bytes(32), padding: false),
      public_key: webauthn_private_key.public_to_der,
      sign_count: 0,
      transports: [ "internal" ]
    )
  end

  test "successful authentication" do
    untenanted do
      challenge = request_webauthn_challenge

      post session_passkey_url, params: build_assertion_params(challenge: challenge, credential: @credential)

      assert_response :redirect
      assert cookies[:session_token].present?
    end
  end

  test "updates sign count" do
    untenanted do
      challenge = request_webauthn_challenge

      post session_passkey_url, params: build_assertion_params(challenge: challenge, credential: @credential, sign_count: 1)

      assert_equal 1, @credential.reload.sign_count
    end
  end

  test "rejects invalid signature" do
    untenanted do
      challenge = request_webauthn_challenge

      params = build_assertion_params(challenge: challenge, credential: @credential)
      params[:passkey][:signature] = Base64.urlsafe_encode64("invalid", padding: false)

      post session_passkey_url, params: params

      assert_redirected_to new_session_path
      assert_not cookies[:session_token].present?
    end
  end

  test "rejects unknown credential" do
    untenanted do
      request_webauthn_challenge

      post session_passkey_url, params: {
        passkey: {
          id: "nonexistent",
          client_data_json: Base64.urlsafe_encode64("{}", padding: false),
          authenticator_data: Base64.urlsafe_encode64("x", padding: false),
          signature: Base64.urlsafe_encode64("x", padding: false)
        }
      }

      assert_redirected_to new_session_path
      assert_not cookies[:session_token].present?
    end
  end
end

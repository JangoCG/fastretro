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

  test "persists the full unsigned 32 bit authenticator counter" do
    untenanted do
      challenge = request_webauthn_challenge
      post session_passkey_url, params: build_assertion_params(challenge:, credential: @credential, sign_count: 4_294_967_295)

      assert_response :redirect
      assert_equal 4_294_967_295, @credential.reload.sign_count
      assert cookies[:session_token].present?
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

  test "malformed assertion fields return an authentication failure" do
    untenanted do
      [ [ :client_data_json, 42 ], [ :client_data_json, "[]" ], [ :authenticator_data, 42 ], [ :signature, 42 ] ].each do |field, value|
        challenge = request_webauthn_challenge
        attributes = build_assertion_params(challenge:, credential: @credential)
        attributes[:passkey][field] = value

        assert_no_difference "Session.count" do
          post session_passkey_url, params: attributes
        end

        assert_redirected_to new_session_path
        assert_equal I18n.t("flash.passkey_failed"), flash[:alert]
        assert_not cookies[:session_token].present?
      end
    end
  end

  test "JSON authentication uses the browser redirect without returning the session token" do
    untenanted do
      challenge = request_webauthn_challenge
      post session_passkey_url, params: build_assertion_params(challenge:, credential: @credential), as: :json

      assert_redirected_to session_menu_path
      assert cookies[:session_token].present?
      assert_not_includes response.body, cookies[:session_token]
    end
  end
end

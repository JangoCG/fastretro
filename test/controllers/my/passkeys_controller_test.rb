require "test_helper"

class My::PasskeysControllerTest < ActionDispatch::IntegrationTest
  include WebauthnTestHelper

  setup do
    sign_in_as :one
  end

  test "index" do
    get my_passkeys_path
    assert_response :success
  end

  test "register a passkey" do
    challenge = request_webauthn_challenge(purpose: "registration")

    assert_difference -> { identities(:one).passkeys.count }, 1 do
      post my_passkeys_path, params: build_attestation_params(challenge: challenge)
    end

    passkey = identities(:one).passkeys.order(created_at: :desc).first
    assert_redirected_to edit_my_passkey_path(passkey, created: true)
    assert_equal [ "internal" ], passkey.transports
  end

  test "edit a passkey" do
    passkey = identities(:one).passkeys.create!(
      name: "Test",
      credential_id: Base64.urlsafe_encode64(SecureRandom.random_bytes(32), padding: false),
      public_key: webauthn_private_key.public_to_der,
      sign_count: 0
    )

    get edit_my_passkey_path(passkey)
    assert_response :success
  end

  test "update a passkey name" do
    passkey = identities(:one).passkeys.create!(
      name: "Old Name",
      credential_id: Base64.urlsafe_encode64(SecureRandom.random_bytes(32), padding: false),
      public_key: webauthn_private_key.public_to_der,
      sign_count: 0
    )

    patch my_passkey_path(passkey), params: { passkey: { name: "MacBook Pro" } }
    assert_redirected_to my_passkeys_path
    assert_equal "MacBook Pro", passkey.reload.name
  end

  test "destroy a passkey" do
    passkey = identities(:one).passkeys.create!(
      name: "To Delete",
      credential_id: Base64.urlsafe_encode64(SecureRandom.random_bytes(32), padding: false),
      public_key: webauthn_private_key.public_to_der,
      sign_count: 0
    )

    assert_difference -> { identities(:one).passkeys.count }, -1 do
      delete my_passkey_path(passkey)
    end
    assert_redirected_to my_passkeys_path
  end
end

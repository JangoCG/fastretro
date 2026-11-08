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

  test "malformed registration fields are rejected without saving a passkey" do
    [ [ :client_data_json, 42 ], [ :client_data_json, "[]" ], [ :attestation_object, 42 ],
      [ :attestation_object, Base64.urlsafe_encode64("\xc2\x01".b) ] ].each do |field, value|
      challenge = request_webauthn_challenge(purpose: "registration")
      attributes = build_attestation_params(challenge:)
      attributes[:passkey][field] = value

      assert_no_difference -> { identities(:one).passkeys.count } do
        post my_passkeys_path, params: attributes, as: :json
      end

      assert_redirected_to my_passkeys_path
      assert_equal "We couldn't register that passkey. Please try again.", flash[:alert]
    end
  end

  test "duplicate registration reports that the passkey is already registered" do
    credential_id = SecureRandom.random_bytes(32)
    challenge = request_webauthn_challenge(purpose: "registration")
    post my_passkeys_path, params: build_attestation_params(challenge:, credential_id:)
    assert_response :redirect

    challenge = request_webauthn_challenge(purpose: "registration")
    assert_no_difference -> { identities(:one).passkeys.count } do
      post my_passkeys_path, params: build_attestation_params(challenge:, credential_id:)
    end

    assert_redirected_to my_passkeys_path
    assert_equal "That passkey is already registered.", flash[:alert]
  end

  test "registration without attested credential data is rejected" do
    challenge = request_webauthn_challenge(purpose: "registration")
    attributes = build_attestation_params(challenge:)
    prefix = [ "a363666d74646e6f6e656761747453746d74a06861757468446174615825" ].pack("H*")
    attributes[:passkey][:attestation_object] = Base64.urlsafe_encode64(prefix + build_assertion_auth_data(sign_count: 0), padding: false)

    assert_no_difference -> { identities(:one).passkeys.count } do
      post my_passkeys_path, params: attributes
    end

    assert_redirected_to my_passkeys_path
    assert_equal "We couldn't register that passkey. Please try again.", flash[:alert]
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

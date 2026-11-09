require "test_helper"

class ActionPack::WebAuthnSecurityTest < ActiveSupport::TestCase
  include WebauthnTestHelper

  test "malformed indefinite CBOR strings and bignums produce controlled errors" do
    {
      "5f5fffff" => "Indefinite-length string chunk must be a definite-length string of the same type",
      "5f00ff" => "Indefinite-length string chunk must be a definite-length string of the same type",
      "5f40" => "Unexpected end of input",
      "c201" => "Bignum value must be a byte string"
    }.each do |hex, message|
      error = assert_raises(ActionPack::WebAuthn::InvalidCborError) do
        ActionPack::WebAuthn::CborDecoder.decode([ hex ].pack("H*"))
      end
      assert_equal message, error.message
    end
  end

  test "CBOR container sizes are checked before allocating their declared length" do
    [ "9a00000400", "ba00000400" ].each do |hex|
      error = assert_raises(ActionPack::WebAuthn::InvalidCborError) do
        ActionPack::WebAuthn::CborDecoder.decode([ hex ].pack("H*"))
      end
      assert_equal "Declared length exceeds remaining input", error.message
    end
  end

  test "CBOR rejects definite and indefinite containers above the element budget" do
    [ "850000000000", "9f0000000000ff", "a3000000000000", "bf000000000000ff", "5f4040404040ff", "7f6060606060ff" ].each do |hex|
      assert_raises(ActionPack::WebAuthn::InvalidCborError) do
        ActionPack::WebAuthn::CborDecoder.decode([ hex ].pack("H*"), max_elements: 2)
      end
    end

    assert_equal [ 0, 0 ], ActionPack::WebAuthn::CborDecoder.decode([ "820000" ].pack("H*"), max_elements: 2)
  end

  test "the default CBOR element budget accepts 65536 entries and rejects 65537" do
    accepted = "\x9a".b + [ 65_536 ].pack("N") + "\x00".b * 65_536
    rejected = "\x9a".b + [ 65_537 ].pack("N") + "\x00".b * 65_537

    assert_equal 65_536, ActionPack::WebAuthn::CborDecoder.decode(accepted).size
    assert_raises(ActionPack::WebAuthn::InvalidCborError) { ActionPack::WebAuthn::CborDecoder.decode(rejected) }
  end

  test "CBOR byte limits apply before expanding strings into byte arrays" do
    oversized = "\x00".b * 5
    oversized.expects(:bytes).never

    assert_raises(ActionPack::WebAuthn::InvalidCborError) do
      ActionPack::WebAuthn::CborDecoder.decode(oversized, max_size: 4)
    end
  end

  test "CBOR bignums are bounded to one kibibyte" do
    oversized = [ "c2590401" ].pack("H*") + "\x00".b * 1025
    assert_raises(ActionPack::WebAuthn::InvalidCborError) do
      ActionPack::WebAuthn::CborDecoder.decode(oversized)
    end

    accepted = [ "c2590400" ].pack("H*") + "\x00".b * 1024
    assert_equal 0, ActionPack::WebAuthn::CborDecoder.decode(accepted)
  end

  test "RSA keys are checked using their actual bit length and exponent" do
    [
      { -1 => "\x00".b * 255 + "\x03".b, -2 => "\x01\x00\x01".b },
      { -1 => "\xff".b * 256, -2 => "\x01".b },
      { -1 => "\xff".b * 256, -2 => "\x02".b },
      { -1 => "\xff".b * 256, -2 => "\x04".b },
      { -1 => 42, -2 => "\x01\x00\x01".b }
    ].each do |parameters|
      assert_raises(ActionPack::WebAuthn::InvalidKeyError) do
        ActionPack::WebAuthn::CoseKey.new(key_type: 3, algorithm: -257, parameters:).to_openssl_key
      end
    end

    rsa = OpenSSL::PKey::RSA.generate(2048)
    key = ActionPack::WebAuthn::CoseKey.new(key_type: 3, algorithm: -257, parameters: { -1 => rsa.n.to_s(2), -2 => rsa.e.to_s(2) })
    assert_equal rsa.public_to_der, key.to_openssl_key.public_to_der
  end

  test "COSE data and EC coordinates must have the expected types" do
    assert_raises(ActionPack::WebAuthn::InvalidKeyError) { ActionPack::WebAuthn::CoseKey.decode("\x01".b) }
    assert_raises(ActionPack::WebAuthn::InvalidKeyError) do
      ActionPack::WebAuthn::CoseKey.new(key_type: 2, algorithm: -7, parameters: { -1 => 1, -2 => 42, -3 => 42 }).to_openssl_key
    end
    assert_raises(ActionPack::WebAuthn::InvalidKeyError) do
      ActionPack::WebAuthn::CoseKey.new(key_type: 1, algorithm: -8, parameters: { -1 => 6, -2 => 42 }).to_openssl_key
    end
  end

  test "oversized authenticator inputs are rejected before Base64 allocation" do
    oversized = "A" * (10.megabytes / 3 * 4 + 5)
    Base64.expects(:urlsafe_decode64).never

    [ ActionPack::WebAuthn::Authenticator::Data, ActionPack::WebAuthn::Authenticator::Attestation ].each do |type|
      assert_raises(ActionPack::WebAuthn::InvalidResponseError) { type.wrap(oversized) }
    end
  end

  test "already decoded authenticator data and attestations remain accepted" do
    ActionPack::WebAuthn::Current.host = "www.example.com"
    origin = "http://www.example.com"
    credential = Struct.new(:credential_id, :public_key, :sign_count).new("test-credential", webauthn_private_key, 0)
    challenge = webauthn_challenge(purpose: "authentication")
    attributes = build_assertion_params(challenge:, credential:)[:passkey]
    data = ActionPack::WebAuthn::Authenticator::Data.decode(build_assertion_auth_data(sign_count: 1))
    assertion = ActionPack::WebAuthn::Authenticator::AssertionResponse.new(credential:, origin:,
      client_data_json: attributes[:client_data_json], authenticator_data: data,
      signature: Base64.urlsafe_decode64(attributes[:signature]))
    assert assertion.valid?, assertion.errors.full_messages.join(", ")

    challenge = webauthn_challenge(purpose: "registration")
    attributes = build_attestation_params(challenge:)[:passkey]
    attestation = ActionPack::WebAuthn::Authenticator::Attestation.wrap(attributes[:attestation_object])
    registration = ActionPack::WebAuthn::Authenticator::AttestationResponse.new(origin:,
      client_data_json: attributes[:client_data_json], attestation_object: attestation)
    assert registration.valid?, registration.errors.full_messages.join(", ")
  end
end

require "test_helper"

class SignupTest < ActiveSupport::TestCase
  test "validates email format for identity creation" do
    signup = Signup.new(email_address: "not-an-email")
    assert_not signup.valid?(:identity_creation)
    assert signup.errors[:email_address].any?

    signup = Signup.new(email_address: "valid@example.com")
    assert signup.valid?(:identity_creation)
  end

  test "#create_identity" do
    signup = Signup.new(email_address: "brian-#{SecureRandom.hex(6)}@example.com")

    magic_link = nil
    assert_difference -> { Identity.count }, 1 do
      assert_difference -> { MagicLink.count }, 1 do
        magic_link = signup.create_identity
      end
    end

    assert_kind_of MagicLink, magic_link
    assert_empty signup.errors
    assert signup.identity
    assert signup.identity.persisted?

    signup_existing = Signup.new(email_address: signup.email_address)

    assert_no_difference -> { Identity.count } do
      assert_difference -> { MagicLink.count }, 1 do
        magic_link = signup_existing.create_identity
      end
    end

    assert_kind_of MagicLink, magic_link
  end

  test "#complete" do
    Current.without_account do
      signup = Signup.new(full_name: "Test User", identity: identities(:admin))

      assert signup.complete

      assert signup.account
      assert signup.user
      assert_equal "Test User", signup.user.name

      signup_invalid = Signup.new(
        full_name: "",
        identity: identities(:admin)
      )
      assert_not signup_invalid.complete
      assert_not_empty signup_invalid.errors[:full_name]
    end
  end

  test "#complete with invalid data" do
    Current.without_account do
      signup = Signup.new
      assert_not signup.complete
      assert signup.errors[:full_name].any?
      assert signup.errors[:identity].any?
      assert_nil signup.account
      assert_nil signup.user
    end
  end
end

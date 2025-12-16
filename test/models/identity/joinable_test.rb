require "test_helper"

class Identity::JoinableTest < ActiveSupport::TestCase
  test "join creates a new user and returns true" do
    identity = identities(:one)

    assert_difference -> { User.count }, 1 do
      result = identity.join(accounts(:two))
      assert result, "join should return true when creating a new user"
    end

    user = identity.users.find_by!(account: accounts(:two))
    assert_equal identity.email_address, user.name
  end

  test "join with custom attributes" do
    identity = identities(:other)

    result = identity.join(accounts(:one), name: "Other User")
    assert result

    user = identity.users.find_by!(account: accounts(:one))
    assert_equal "Other User", user.name
  end

  test "join returns false if user already exists" do
    identity = identities(:one)
    account = accounts(:one)

    assert identity.users.exists?(account: account), "One should already be a member of account one"

    assert_no_difference -> { User.count } do
      result = identity.join(account)
      assert_not result, "join should return false when user already exists"
    end
  end
end

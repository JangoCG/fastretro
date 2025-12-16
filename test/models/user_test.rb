require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "active scope returns active users" do
    user = users(:one)
    assert user.active?
    assert_includes User.active, user
  end

  test "alphabetically scope orders by name" do
    users = User.alphabetically
    assert_equal users.pluck(:name), users.pluck(:name).sort
  end

  test "deactivate sets active to false and removes identity" do
    user = users(:one)
    user.deactivate
    assert_not user.active?
    assert_nil user.identity
  end

  test "setup?" do
    user = users(:admin)

    user.update!(name: user.identity.email_address)
    assert_not user.setup?

    user.update!(name: "Admin")
    assert user.setup?
  end

  test "verified? returns true when verified_at is present" do
    user = users(:one)
    user.update_column(:verified_at, Time.current)

    assert user.verified?
  end

  test "verified? returns false when verified_at is nil" do
    user = users(:one)
    user.update_column(:verified_at, nil)

    assert_not user.verified?
  end

  test "verify sets verified_at when not already verified" do
    user = users(:one)
    user.update_column(:verified_at, nil)

    assert_nil user.verified_at
    user.verify
    assert_not_nil user.reload.verified_at
  end

  test "verify does not update verified_at when already verified" do
    user = users(:one)
    original_time = 1.day.ago
    user.update_column(:verified_at, original_time)

    user.verify
    assert_equal original_time.to_i, user.reload.verified_at.to_i
  end
end

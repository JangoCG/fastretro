require "test_helper"

class User::RoleTest < ActiveSupport::TestCase
  test "can administer others?" do
    assert users(:admin).can_administer?(users(:two))

    assert_not users(:admin).can_administer?(users(:admin))
    assert_not users(:two).can_administer?(users(:admin))
  end

  test "owner can administer admins and members" do
    assert users(:one).can_administer?(users(:admin))
    assert users(:one).can_administer?(users(:two))
  end

  test "owner cannot administer themselves" do
    assert_not users(:one).can_administer?(users(:one))
  end

  test "admin cannot administer the owner" do
    assert_not users(:admin).can_administer?(users(:one))
  end

  test "owner is included in active scope" do
    active_users = User.active
    assert_includes active_users, users(:one)
    assert_includes active_users, users(:admin)
    assert_includes active_users, users(:two)
  end

  test "owner is also considered an admin" do
    assert users(:one).owner?
    assert users(:one).admin?

    assert users(:admin).admin?
    assert_not users(:admin).owner?
  end

  test "owner scope returns only active owners" do
    owners = accounts(:one).users.owner
    assert_includes owners, users(:one)
    assert_not_includes owners, users(:admin)
    assert_not_includes owners, users(:two)

    users(:one).update!(active: false)
    assert_not_includes accounts(:one).users.owner, users(:one)
  end

  test "admin scope returns active owners and admins" do
    admins = accounts(:one).users.admin
    assert_includes admins, users(:one)
    assert_includes admins, users(:admin)
    assert_not_includes admins, users(:two)

    users(:admin).update!(active: false)
    assert_not_includes accounts(:one).users.admin, users(:admin)
  end
end

require "test_helper"

class Users::RolesControllerTest < ActionDispatch::IntegrationTest
  test "admins promote and demote members through the web form" do
    sign_in_as :admin
    %w[ admin member ].each do |role|
      put user_role_path(users(:two)), params: { user: { role: role } }
      assert_redirected_to account_settings_path
      assert_equal role, users(:two).reload.role
    end
  end

  test "members cannot administer users and admins cannot change owners or themselves" do
    [ [ :two, :admin ], [ :admin, :one ], [ :admin, :admin ] ].each do |actor, target|
      sign_in_as actor
      original_role = users(target).role
      put user_role_path(users(target)), params: { user: { role: "member" } }
      assert_response :forbidden
      assert_equal original_role, users(target).reload.role
    end
  end

  test "role updates never promote to owner or system" do
    sign_in_as :admin
    %w[ owner system unknown ].each do |role|
      put user_role_path(users(:two)), params: { user: { role: role } }
      assert_redirected_to account_settings_path
      assert users(:two).reload.member?
    end
  end

  test "inactive users and users outside the account cannot receive role updates" do
    sign_in_as :admin
    users(:two).update!(active: false)
    [ users(:two), users(:other_account_owner) ].each do |user|
      original_role = user.role
      put user_role_path(user), params: { user: { role: "admin" } }
      assert_response :not_found
      assert_equal original_role, user.reload.role
    end
  end
end

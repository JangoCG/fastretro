require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "members cannot rename other members admins or owners" do
    sign_in_as :two
    other_member = accounts(:one).users.create!(name: "Another member", identity: identities(:staff), role: :member)
    [ other_member, users(:admin), users(:one) ].each do |user|
      original_name = user.name
      patch user_path(user), params: { user: { name: "Unauthorized rename" } }
      assert_response :forbidden
      assert_equal original_name, user.reload.name
    end
  end

  test "members update themselves without changing protected attributes in HTML and existing JSON requests" do
    sign_in_as :two
    user = users(:two)
    attributes = { name: "Renamed member", role: "owner", active: false, account_id: accounts(:two).id, identity_id: identities(:staff).id }
    [ :html, :json ].each do |format|
      patch user_path(user), params: { user: attributes }, as: format
      if format == :html
        assert_redirected_to user_path(user)
      else
        assert_response :no_content
      end
      assert_equal "Renamed member", user.reload.name
      assert_equal "member", user.role
      assert_equal accounts(:one).id, user.account_id
      assert_equal identities(:two).id, user.identity_id
      assert user.active?
    end
  end

  test "admins update themselves and members" do
    sign_in_as :admin
    [ users(:two), users(:admin) ].each do |user|
      patch user_path(user), params: { user: { name: "Updated by admin" } }
      assert_redirected_to user_path(user)
      assert_equal "Updated by admin", user.reload.name
    end
  end

  test "admins cannot rename an owner and owners cannot rename other owners" do
    [ :admin, :one ].each do |actor|
      sign_in_as actor
      target = actor == :one ? accounts(:one).users.create!(name: "Other owner", identity: identities(:staff), role: :owner) : users(:one)
      original_name = target.name
      patch user_path(target), params: { user: { name: "Unauthorized rename" } }
      assert_response :forbidden
      assert_equal original_name, target.reload.name
    end
  end

  test "owners can rename themselves" do
    sign_in_as :one
    patch user_path(users(:one)), params: { user: { name: "Renamed owner" } }
    assert_redirected_to user_path(users(:one))
    assert_equal "Renamed owner", users(:one).reload.name
  end

  test "the browser profile retains passkeys and transfers without an API token link or JSON profile" do
    sign_in_as :one
    get user_path(users(:one))
    assert_response :success
    assert_select "a[href=?]", my_passkeys_path
    assert_select "a[href*='/my/access_tokens']", count: 0
    assert_select "input#session_transfer_url[readonly]" do |inputs|
      assert_includes inputs.first["value"], "/session/transfers/"
    end

    get user_path(users(:one)), as: :json
    assert_response :not_acceptable
  end

  test "inactive users and users of another account are not exposed or changed" do
    sign_in_as :admin
    inactive = users(:two)
    inactive.update!(active: false)
    [ inactive, users(:other_account_owner) ].each do |user|
      original_name = user.name
      get user_path(user)
      assert_response :not_found
      patch user_path(user), params: { user: { name: "Unauthorized rename" } }
      assert_response :not_found
      delete user_path(user)
      assert_response :not_found
      assert_equal original_name, user.reload.name
    end
  end

  test "HTML deletion deactivates the member and retains its redirect and notice" do
    sign_in_as :admin
    delete user_path(users(:two))
    assert_redirected_to account_settings_path
    assert_equal I18n.t("flash.user_removed", name: users(:two).name), flash[:notice]
    assert_not users(:two).reload.active?
    assert_nil users(:two).identity
  end

  test "deletion retains the existing restrictions on owners and self removal" do
    [ [ :two, :admin ], [ :admin, :one ], [ :admin, :admin ], [ :one, :one ] ].each do |actor, target|
      sign_in_as actor
      delete user_path(users(target))
      assert_response :forbidden
      assert users(target).reload.active?
    end
  end
end

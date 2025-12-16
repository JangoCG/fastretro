require "test_helper"

class Sessions::MenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity = identities(:admin)
  end

  test "show with no account" do
    sign_in_as @identity
    @identity.users.delete_all

    untenanted do
      get session_menu_url
    end

    assert_response :success, "Renders an empty menu"
  end

  test "show with exactly one account" do
    sign_in_as @identity

    Current.without_account do
      @identity.users.delete_all
      account = Account.create!(external_account_id: 9999991, name: "Test Account")
      @identity.users.create!(account: account, name: "Admin")
    end

    untenanted do
      get session_menu_url
    end

    assert_response :redirect
    assert_redirected_to root_url(script_name: "/9999991")
  end

  test "show with multiple accounts" do
    sign_in_as @identity
    @identity.users.delete_all
    account1 = Account.create!(external_account_id: 9999992, name: "Account 1")
    account2 = Account.create!(external_account_id: 9999993, name: "Account 2")
    @identity.users.create!(account: account1, name: "Admin")
    @identity.users.create!(account: account2, name: "Admin")

    untenanted do
      get session_menu_url
    end

    assert_response :success
  end
end

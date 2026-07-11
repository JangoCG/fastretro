require "test_helper"

class My::MenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as :one
  end

  test "shows a premium upgrade nudge to admins of free SaaS accounts" do
    FastRetro.stubs(:saas?).returns(true)

    get my_menu_path

    assert_response :success
    assert_select "#premium-upgrade-nudge" do
      assert_select "form[action=?][method=post]", account_subscription_path
    end
  end

  test "does not show the premium upgrade nudge outside SaaS mode" do
    FastRetro.stubs(:saas?).returns(false)

    get my_menu_path

    assert_response :success
    assert_select "#premium-upgrade-nudge", count: 0
  end

  test "does not show the premium upgrade nudge to members" do
    logout_and_sign_in_as :two
    FastRetro.stubs(:saas?).returns(true)

    get my_menu_path

    assert_response :success
    assert_select "#premium-upgrade-nudge", count: 0
  end

  test "removes the premium upgrade nudge when the account becomes paid" do
    FastRetro.stubs(:saas?).returns(true)

    get my_menu_path
    free_plan_etag = response.headers["ETag"]

    @account.comp
    get my_menu_path, headers: { "If-None-Match" => free_plan_etag }

    assert_response :success
    assert_select "#premium-upgrade-nudge", count: 0
  end
end

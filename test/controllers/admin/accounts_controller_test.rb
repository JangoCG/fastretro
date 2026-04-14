require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "staff can access account edit page" do
    sign_in_as :staff

    untenanted do
      get edit_admin_account_path(accounts(:one).external_account_id)
    end

    assert_response :success
    assert_in_body "Test Account"
    assert_in_body accounts(:one).external_account_id.to_s
  end

  test "non-staff cannot access account edit page" do
    sign_in_as :one

    untenanted do
      get edit_admin_account_path(accounts(:one).external_account_id)
    end

    assert_redirected_to session_menu_url(script_name: nil)
  end

  test "unauthenticated user cannot access account edit page" do
    untenanted do
      get edit_admin_account_path(accounts(:one).external_account_id)
    end

    assert_redirected_to root_url(script_name: nil)
  end
end

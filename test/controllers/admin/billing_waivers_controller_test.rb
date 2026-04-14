require "test_helper"

class Admin::BillingWaiversControllerTest < ActionDispatch::IntegrationTest
  test "staff can comp an account" do
    sign_in_as :staff
    account = accounts(:one)

    assert_not account.comped?

    untenanted do
      post admin_account_billing_waiver_path(account.external_account_id)
      assert_redirected_to edit_admin_account_path(account.external_account_id)
    end

    assert account.reload.comped?
  end

  test "staff can uncomp an account" do
    sign_in_as :staff
    account = accounts(:one)
    account.comp

    assert account.comped?

    untenanted do
      delete admin_account_billing_waiver_path(account.external_account_id)
      assert_redirected_to edit_admin_account_path(account.external_account_id)
    end

    assert_not account.reload.comped?
  end

  test "comping an already comped account is idempotent" do
    sign_in_as :staff
    account = accounts(:one)
    account.comp

    untenanted do
      post admin_account_billing_waiver_path(account.external_account_id)
      assert_redirected_to edit_admin_account_path(account.external_account_id)
    end

    assert_equal 1, Account::BillingWaiver.where(account: account).count
  end

  test "non-staff cannot comp an account" do
    sign_in_as :one
    account = accounts(:two)

    untenanted do
      post admin_account_billing_waiver_path(account.external_account_id)
    end

    assert_redirected_to session_menu_url(script_name: nil)
    assert_not account.reload.comped?
  end

  test "non-staff cannot uncomp an account" do
    sign_in_as :one
    account = accounts(:two)
    account.comp

    untenanted do
      delete admin_account_billing_waiver_path(account.external_account_id)
    end

    assert_redirected_to session_menu_url(script_name: nil)
    assert account.reload.comped?
  end
end

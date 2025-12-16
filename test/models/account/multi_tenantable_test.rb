require "test_helper"

class Account::MultiTenantableTest < ActiveSupport::TestCase
  test "accepting_signups? is true when multi_tenant is enabled" do
    with_multi_tenant_mode(true) do
      assert Account.accepting_signups?
    end
  end

  test "accepting_signups? is false when multi_tenant is disabled and accounts exist" do
    with_multi_tenant_mode(false) do
      assert_not Account.accepting_signups?
    end
  end

  test "accepting_signups? is true when multi_tenant is disabled but no accounts exist" do
    with_multi_tenant_mode(false) do
      Account.connection.disable_referential_integrity do
        Retro.delete_all
        Account::JoinCode.delete_all
        User.delete_all
        Account.delete_all
      end
      assert Account.accepting_signups?
    end
  end
end

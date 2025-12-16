require "test_helper"

class Account::JoinCodeTest < ActiveSupport::TestCase
  test "generate code" do
    join_code = Account::JoinCode.create!(account: Current.account)

    assert join_code.code.present?

    parts = join_code.code.split("-")
    assert_equal 3, parts.count
  end

  test "redeem_if increments usage_count when block returns true" do
    join_code = account_join_codes(:one)

    assert_difference -> { join_code.reload.usage_count }, +1 do
      join_code.redeem_if { true }
    end
  end

  test "redeem_if does not increment usage_count when block returns false" do
    join_code = account_join_codes(:one)

    assert_no_difference -> { join_code.reload.usage_count } do
      join_code.redeem_if { false }
    end
  end

  test "reset" do
    join_code = account_join_codes(:one)
    original_code = join_code.code

    join_code.reset

    assert_not_equal original_code, join_code.code
    assert_equal 0, join_code.usage_count
  end

  test "active?" do
    join_code = account_join_codes(:one)
    assert join_code.active?

    exhausted_join_code = account_join_codes(:two)
    assert_not exhausted_join_code.active?
  end
end

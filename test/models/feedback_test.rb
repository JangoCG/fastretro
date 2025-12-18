require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  setup do
    @retro = retros(:one)
    @owner_identity = identities(:one)
    @user = users(:one)
    Current.user = @user
  end

  teardown do
    FastRetro.reset_saas!
  end

  # === Publish Tests ===

  test "publish changes status to published" do
    feedback = Feedback.create!(retro: @retro, user: @user, category: :went_well, status: :drafted)

    feedback.publish

    assert feedback.published?
  end

  test "publish increments account feedbacks_count in saas mode" do
    enable_saas_mode
    @retro.account.update!(feedbacks_count: 0)

    feedback = Feedback.create!(retro: @retro, user: @user, category: :went_well, status: :drafted)

    assert_difference -> { @retro.account.reload.feedbacks_count }, 1 do
      feedback.publish
    end
  end

  test "publish does not increment count when not in saas mode" do
    disable_saas_mode
    @retro.account.update!(feedbacks_count: 0)

    feedback = Feedback.create!(retro: @retro, user: @user, category: :went_well, status: :drafted)

    assert_no_difference -> { @retro.account.reload.feedbacks_count } do
      feedback.publish
    end
  end

  test "publish raises LimitReached when account has reached limit in saas mode" do
    enable_saas_mode
    @retro.account.update!(feedbacks_count: Plan.free.feedback_limit)

    feedback = Feedback.create!(retro: @retro, user: @user, category: :went_well, status: :drafted)

    assert_raises Feedback::Statuses::LimitReached do
      feedback.publish
    end
  end

  test "publish allows publishing when account has active subscription even over limit" do
    enable_saas_mode
    @retro.account.update!(feedbacks_count: Plan.free.feedback_limit + 100)
    # Create active subscription for account
    @retro.account.create_subscription!(
      plan_key: :monthly_v1,
      stripe_customer_id: "cus_test",
      status: "active"
    )

    feedback = Feedback.create!(retro: @retro, user: @user, category: :went_well, status: :drafted)

    assert_nothing_raised do
      feedback.publish
    end

    assert feedback.published?
  end

  test "publish does not check limit when not in saas mode" do
    disable_saas_mode
    @retro.account.update!(feedbacks_count: Plan.free.feedback_limit + 100)

    feedback = Feedback.create!(retro: @retro, user: @user, category: :went_well, status: :drafted)

    assert_nothing_raised do
      feedback.publish
    end
  end

  # === Guest User Tests ===

  test "guest user publishing counts towards account feedbacks_count" do
    enable_saas_mode
    guest_user = users(:two) # member, not owner
    @retro.account.update!(feedbacks_count: 0)

    feedback = Feedback.create!(retro: @retro, user: guest_user, category: :went_well, status: :drafted)

    assert_difference -> { @retro.account.reload.feedbacks_count }, 1 do
      feedback.publish
    end
  end

  private

  def enable_saas_mode
    FastRetro.saas = true
  end

  def disable_saas_mode
    FastRetro.saas = false
  end
end

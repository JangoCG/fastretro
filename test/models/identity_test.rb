require "test_helper"

class IdentityTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  # === Subscription Tests ===

  test "active? returns true when subscription_ends_at is in the future" do
    identity = identities(:one)
    identity.subscription_ends_at = 1.month.from_now

    assert identity.active?
  end

  test "active? returns false when subscription_ends_at is in the past" do
    identity = identities(:one)
    identity.subscription_ends_at = 1.day.ago

    assert_not identity.active?
  end

  test "active? returns false when subscription_ends_at is nil" do
    identity = identities(:one)
    identity.subscription_ends_at = nil

    assert_not identity.active?
  end

  # === Feedback Limit Tests ===

  test "feedback_limit_reached? returns true when at or over limit and not active" do
    identity = identities(:one)
    identity.subscription_ends_at = nil
    accounts(:one).update!(feedbacks_count: Identity::FREE_FEEDBACK_LIMIT)

    assert identity.feedback_limit_reached?
  end

  test "feedback_limit_reached? returns false when under limit" do
    identity = identities(:one)
    identity.subscription_ends_at = nil
    accounts(:one).update!(feedbacks_count: Identity::FREE_FEEDBACK_LIMIT - 1)

    assert_not identity.feedback_limit_reached?
  end

  test "feedback_limit_reached? returns false when active subscriber" do
    identity = identities(:one)
    identity.subscription_ends_at = 1.month.from_now
    accounts(:one).update!(feedbacks_count: Identity::FREE_FEEDBACK_LIMIT + 100)

    assert_not identity.feedback_limit_reached?
  end

  test "near_feedback_limit? returns true at 80% of limit" do
    identity = identities(:one)
    identity.subscription_ends_at = nil
    # With limit of 3, 80% threshold is 2.4, so count >= 3 triggers near_limit
    accounts(:one).update!(feedbacks_count: (Identity::FREE_FEEDBACK_LIMIT * 0.8).ceil)

    assert identity.near_feedback_limit?
  end

  test "near_feedback_limit? returns false when active subscriber" do
    identity = identities(:one)
    identity.subscription_ends_at = 1.month.from_now
    accounts(:one).update!(feedbacks_count: Identity::FREE_FEEDBACK_LIMIT)

    assert_not identity.near_feedback_limit?
  end

  test "feedbacks_remaining returns correct count" do
    identity = identities(:one)
    identity.subscription_ends_at = nil
    accounts(:one).update!(feedbacks_count: 2)

    assert_equal Identity::FREE_FEEDBACK_LIMIT - 2, identity.feedbacks_remaining
  end

  test "feedbacks_remaining returns 0 when over limit" do
    identity = identities(:one)
    identity.subscription_ends_at = nil
    accounts(:one).update!(feedbacks_count: Identity::FREE_FEEDBACK_LIMIT + 5)

    assert_equal 0, identity.feedbacks_remaining
  end

  test "feedbacks_remaining returns infinity for active subscribers" do
    identity = identities(:one)
    identity.subscription_ends_at = 1.month.from_now

    assert_equal Float::INFINITY, identity.feedbacks_remaining
  end

  test "total_feedbacks_count sums feedbacks from owned accounts" do
    identity = identities(:one)
    accounts(:one).update!(feedbacks_count: 42)

    assert_equal 42, identity.total_feedbacks_count
  end

  # === Existing Tests ===

  test "send_magic_link" do
    identity = identities(:one)

    assert_emails 1 do
      magic_link = identity.send_magic_link
      assert_not_nil magic_link
      assert_equal identity, magic_link.identity
    end
  end

  test "email address format validation" do
    invalid_emails = [
      "sam smith@example.com",       # space in local part
      "@example.com",                # missing local part
      "test@",                       # missing domain
      "test",                        # missing @ and domain
      "<script>@example.com",        # angle brackets
      "test@example.com\nX-Inject:" # newline (header injection attempt)
    ]

    invalid_emails.each do |email|
      identity = Identity.new(email_address: email)
      assert_not identity.valid?, "expected #{email.inspect} to be invalid"
      assert identity.errors[:email_address].any?, "expected error on email_address for #{email.inspect}"
    end
  end

  test "join" do
    identity = identities(:one)
    account = accounts(:two)

    Current.without_account do
      assert_difference "User.count", 1 do
        identity.join(account)
      end

      user = account.users.find_by!(identity: identity)

      assert_not_nil user
      assert_equal identity, user.identity
      assert_equal identity.email_address, user.name
    end
  end

  test "destroy deactivates users before nullifying identity" do
    identity = identities(:admin)
    user = users(:admin)

    assert_predicate user, :active?

    identity.destroy!
    user.reload

    assert_nil user.identity_id, "identity should be nullified"
    assert_not_predicate user, :active?
  end
end

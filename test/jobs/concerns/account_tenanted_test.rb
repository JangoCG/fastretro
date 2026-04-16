require "test_helper"

class AccountTenantedTest < ActiveJob::TestCase
  class CapturingJob < ApplicationJob
    cattr_accessor :captured_account

    def perform(*)
      self.class.captured_account = Current.account
    end
  end

  class RaisingJob < ApplicationJob
    def perform(*)
      raise "boom"
    end
  end

  setup do
    CapturingJob.captured_account = nil
  end

  test "restores Current.account inside perform when enqueued with one" do
    account = accounts(:one)

    Current.set(account: account) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    assert_equal account, CapturingJob.captured_account
  end

  test "passes through when enqueued without an account" do
    Current.set(account: nil) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    assert_nil CapturingJob.captured_account
  end

  test "serializes the account as a GlobalID in job data" do
    account = accounts(:one)

    job = Current.set(account: account) { CapturingJob.new }
    serialized = job.serialize

    assert_equal account.to_gid.to_s, serialized["account"].to_s
  end

  test "clears Current.account after perform finishes" do
    account = accounts(:one)

    Current.set(account: account) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    # Current is cleared between tests, but the point is the around_perform
    # unwinds the account scope even though CurrentAttributes is thread-local.
    # We assert by running a second job without an account and confirming it
    # does not leak the previous one.
    CapturingJob.captured_account = nil
    Current.set(account: nil) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    assert_nil CapturingJob.captured_account
  end

  test "discards the job when the serialized account has been deleted" do
    account = Account.create!(name: "Temp", external_account_id: 9_999_999)

    Current.set(account: account) do
      CapturingJob.perform_later
    end

    account.destroy!

    assert_nothing_raised do
      perform_enqueued_jobs
    end

    assert_nil CapturingJob.captured_account
  end

  test "unwinds the account scope even when the job raises" do
    job_account = accounts(:two)
    outer_account = accounts(:one)
    job = Current.set(account: job_account) { RaisingJob.new }

    Current.set(account: outer_account) do
      assert_raises(RuntimeError) { job.perform_now }

      # The raising job ran with Current.account = job_account (accounts(:two));
      # the around_perform must restore Current.account to the outer value
      # (accounts(:one)) even on the error path.
      assert_equal outer_account, Current.account
    end
  end
end

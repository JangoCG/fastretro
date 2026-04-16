require "test_helper"

class AccountTenantedTest < ActiveJob::TestCase
  class CapturingJob < ApplicationJob
    cattr_accessor :captured_account, :performed_count

    def perform(*)
      self.class.performed_count += 1
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
    CapturingJob.performed_count = 0
  end

  test "restores Current.account inside perform when enqueued with one" do
    account = accounts(:one)

    Current.set(account: account) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    assert_equal 1, CapturingJob.performed_count
    assert_equal account, CapturingJob.captured_account
  end

  test "passes through when enqueued without an account" do
    Current.set(account: nil) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    assert_equal 1, CapturingJob.performed_count
    assert_nil CapturingJob.captured_account
  end

  test "serializes the account as a GlobalID in job data" do
    account = accounts(:one)

    job = Current.set(account: account) { CapturingJob.new }
    serialized = job.serialize

    assert_equal account.to_gid.to_s, serialized["account"].to_s
  end

  test "serializes nil when no account is set at enqueue time" do
    Current.set(account: nil) do
      job = CapturingJob.new
      assert_nil job.serialize["account"]
    end
  end

  test "deserializes a GlobalID URI string and restores the account during perform" do
    account = accounts(:one)

    job = Current.set(account: account) { CapturingJob.new }
    payload = JSON.parse(JSON.dump(job.serialize))

    assert_kind_of String, payload["account"]

    restored = CapturingJob.new
    restored.deserialize(payload)
    restored.perform_now

    assert_equal 1, CapturingJob.performed_count
    assert_equal account, CapturingJob.captured_account
  end

  test "does not leak one job's account into a subsequent job" do
    first_account = accounts(:one)

    Current.set(account: first_account) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    CapturingJob.captured_account = nil
    CapturingJob.performed_count = 0

    Current.set(account: nil) do
      perform_enqueued_jobs { CapturingJob.perform_later }
    end

    assert_equal 1, CapturingJob.performed_count
    assert_nil CapturingJob.captured_account
  end

  test "discards the job when the serialized GlobalID is malformed" do
    job = CapturingJob.new
    job.deserialize(CapturingJob.new.send(:serialize).merge("account" => "gid://fastretro/Account/999999"))

    assert_raises(ActiveJob::DeserializationError) { job.send(:resolve_account!) }
  end

  test "discards the job when the serialized GlobalID cannot be parsed" do
    job = CapturingJob.new
    job.deserialize(CapturingJob.new.send(:serialize).merge("account" => "not-a-valid-gid"))

    assert_raises(ActiveJob::DeserializationError) { job.send(:resolve_account!) }
  end

  test "discards the job when the serialized GlobalID points to a non-Account model" do
    user = users(:one)
    job = CapturingJob.new
    job.deserialize(CapturingJob.new.send(:serialize).merge("account" => user.to_gid.to_s))

    assert_raises(ActiveJob::DeserializationError) { job.send(:resolve_account!) }
  end

  test "prepends AccountTenanted onto ActionMailer::MailDeliveryJob" do
    assert_includes ActionMailer::MailDeliveryJob.ancestors, AccountTenanted
  end

  test "prepends AccountTenanted onto Turbo::Streams broadcast jobs" do
    assert_includes Turbo::Streams::BroadcastJob.ancestors, AccountTenanted
    assert_includes Turbo::Streams::BroadcastStreamJob.ancestors, AccountTenanted
    assert_includes Turbo::Streams::ActionBroadcastJob.ancestors, AccountTenanted
  end

  test "restores Current.account even when the worker has no ambient Current state" do
    account = accounts(:one)

    Current.set(account: account) { CapturingJob.perform_later }

    Current.reset
    perform_enqueued_jobs

    assert_equal 1, CapturingJob.performed_count
    assert_equal account, CapturingJob.captured_account
  end

  test "discards the job when the serialized account has been deleted" do
    account = Account.create!(name: "Temp")

    Current.set(account: account) do
      CapturingJob.perform_later
    end

    account.destroy!

    discards = []
    ActiveSupport::Notifications.subscribed(->(*, payload) { discards << payload }, "discard.active_job") do
      perform_enqueued_jobs
    end

    assert_equal 1, discards.size
    assert_kind_of ActiveJob::DeserializationError, discards.first[:error]
    assert_equal 0, CapturingJob.performed_count
  end

  test "unwinds the account scope even when the job raises" do
    job_account = accounts(:two)
    outer_account = accounts(:one)
    job = Current.set(account: job_account) { RaisingJob.new }

    Current.set(account: outer_account) do
      assert_raises(RuntimeError) { job.perform_now }

      assert_equal outer_account, Current.account
    end
  end

  test "unwinds Current.account after a deserialized raising job" do
    job_account = accounts(:two)
    outer_account = accounts(:one)

    raising = Current.set(account: job_account) { RaisingJob.new }
    payload = JSON.parse(JSON.dump(raising.serialize))

    restored = RaisingJob.new
    restored.deserialize(payload)

    Current.set(account: outer_account) do
      assert_raises(RuntimeError) { restored.perform_now }
      assert_equal outer_account, Current.account
    end
  end
end

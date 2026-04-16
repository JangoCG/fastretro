require "test_helper"

class Retro::JiraExportJobTest < ActiveJob::TestCase
  test "invokes export_actions_to_jira_now on the retro" do
    retro = retros(:one)
    retro.expects(:export_actions_to_jira_now).once

    Current.set(account: retro.account) do
      Retro::JiraExportJob.perform_now(retro)
    end
  end

  test "sets Current.account from the enqueue-time account during perform" do
    retro = retros(:one)

    captured_account = nil
    Retro.any_instance.stubs(:export_actions_to_jira_now).with do
      captured_account = Current.account
      true
    end

    Current.set(account: retro.account) do
      perform_enqueued_jobs { Retro::JiraExportJob.perform_later(retro) }
    end

    assert_equal retro.account, captured_account
  end
end

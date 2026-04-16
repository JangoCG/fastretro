require "test_helper"

class Retro::JiraExportJobTest < ActiveJob::TestCase
  module RecordsCurrentAccount
    def export_actions_to_jira_now
      Retro::JiraExportJobTest.last_account = Current.account
    end
  end

  cattr_accessor :last_account

  setup do
    self.class.last_account = nil
    Retro.prepend(RecordsCurrentAccount)
  end

  test "sets Current.account from the enqueue-time account during perform" do
    retro = retros(:one)

    Current.set(account: retro.account) do
      perform_enqueued_jobs { Retro::JiraExportJob.perform_later(retro) }
    end

    assert_equal retro.account, self.class.last_account
  end
end

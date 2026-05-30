require "test_helper"
require "rake"
require "stringio"

class RetentionRemindersTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.none? { |task| task.name == "retros:retention_reminders:dry_run" }
    Rake::Task["retros:retention_reminders:dry_run"].reenable
    Rake::Task["retros:retention_reminders:enqueue"].reenable

    @retro = retros(:one)
    @retro.update_columns(phase: "complete", retention_reminder_sent_at: nil, created_at: 8.days.ago)
    retros(:two).update_columns(created_at: 9.days.ago)
    @retro.actions.create!(user: users(:one), status: :published, content: "Follow up")
  end

  test "dry run reports eligible retros without enqueueing" do
    assert_no_enqueued_jobs only: Retro::RetentionReminderJob do
      output = capture_stdout { Rake::Task["retros:retention_reminders:dry_run"].invoke }

      assert_includes output, "Eligible retros: 1"
      assert_includes output, "Mode: dry-run"
    end
  end

  test "enqueue schedules eligible retros" do
    assert_enqueued_with job: Retro::RetentionReminderJob, args: [ @retro ] do
      output = capture_stdout { Rake::Task["retros:retention_reminders:enqueue"].invoke }

      assert_includes output, "Eligible retros: 1"
      assert_includes output, "Enqueued reminders: 1"
    end
  end

  private
    def capture_stdout
      original_stdout = $stdout
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = original_stdout
    end
end

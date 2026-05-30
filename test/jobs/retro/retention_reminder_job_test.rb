require "test_helper"

class Retro::RetentionReminderJobTest < ActiveJob::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
    @retro = retros(:one)
    @retro.update_columns(phase: "complete", created_at: 8.days.ago, retention_reminder_sent_at: nil)
    retros(:two).update_columns(created_at: 9.days.ago)
    @retro.actions.create!(user: users(:one), status: :published, content: "Follow up with the team")
  end

  test "sends reminder to retro facilitator" do
    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      Retro::RetentionReminderJob.perform_now(@retro)
    end

    assert @retro.reload.retention_reminder_sent_at.present?
  end

  test "does not send without published actions" do
    @retro.actions.update_all(status: "drafted")

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      Retro::RetentionReminderJob.perform_now(@retro)
    end

    assert_nil @retro.reload.retention_reminder_sent_at
  end

  test "does not send when a newer retro exists" do
    @retro.account.retros.create!(name: "Newer retro")

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      Retro::RetentionReminderJob.perform_now(@retro)
    end

    assert_nil @retro.reload.retention_reminder_sent_at
  end

  test "does not send twice" do
    @retro.update!(retention_reminder_sent_at: Time.current)

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      Retro::RetentionReminderJob.perform_now(@retro)
    end
  end

  test "uses account owner when retro has no facilitator" do
    @retro.participants.destroy_all

    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      Retro::RetentionReminderJob.perform_now(@retro)
    end
  end
end

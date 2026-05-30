class Retro::RetentionReminderJob < ApplicationJob
  include SmtpDeliveryErrorHandling

  def perform(retro)
    retro.deliver_retention_reminder
  end
end

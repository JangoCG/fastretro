Rails.application.config.to_prepare do
  ActionMailer::MailDeliveryJob.prepend AccountTenanted
  ActionMailer::MailDeliveryJob.discard_on ActiveJob::DeserializationError

  [ Turbo::Streams::ActionBroadcastJob, Turbo::Streams::BroadcastJob, Turbo::Streams::BroadcastStreamJob ].each do |job|
    job.prepend AccountTenanted
    job.discard_on ActiveJob::DeserializationError
  end
end

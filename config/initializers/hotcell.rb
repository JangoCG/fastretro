Rails.application.config.to_prepare do
  # A permanently unreadable attachment must not turn a representation request into a 500.
  ActiveStorage::Representations::BaseController.rescue_from FastRetro::Cell::UnprocessableAttachment do |error|
    Rails.error.report error, handled: true, severity: :info
    head :unprocessable_entity
  end

  [ ActiveStorage::CreateVariantsJob, ActiveStorage::TransformJob ].each do |job|
    job.discard_on FastRetro::Cell::UnprocessableAttachment, report: true
  end
end

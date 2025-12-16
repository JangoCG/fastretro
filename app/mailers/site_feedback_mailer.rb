class SiteFeedbackMailer < ApplicationMailer
  def notify(message:, from_email:, from_name:)
    @message = message
    @from_email = from_email
    @from_name = from_name

    mail(
      to: ENV.fetch("SITE_FEEDBACK_EMAIL", "cengiz@cengizg.com"),
      subject: "Site Feedback from #{from_name}",
      reply_to: from_email
    )
  end
end

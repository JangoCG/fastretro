# Preview all emails at http://localhost:3000/rails/mailers/site_feedback_mailer
class SiteFeedbackMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/site_feedback_mailer/notify
  def notify
    SiteFeedbackMailer.notify(
      message: "This is a preview of site feedback. The feature works great!",
      from_email: "user@example.com",
      from_name: "Preview User"
    )
  end
end

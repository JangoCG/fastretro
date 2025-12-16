# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/email_change_confirmation
  def email_change_confirmation
    user = User.first || User.new(name: "Preview User")
    UserMailer.email_change_confirmation(
      email_address: "newemail@example.com",
      token: "abc123def456",
      user: user
    )
  end
end

# Preview all emails at http://localhost:3000/rails/mailers/magic_link_mailer
class MagicLinkMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/magic_link_mailer/sign_in_instructions
  def sign_in_instructions
    magic_link = MagicLink.last || MagicLink.new(
      identity: Identity.first || Identity.new(email_address: "preview@example.com"),
      code: "123456"
    )
    MagicLinkMailer.sign_in_instructions(magic_link)
  end
end

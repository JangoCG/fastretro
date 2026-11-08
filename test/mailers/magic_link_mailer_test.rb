require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  test "sign_in_instructions" do
    magic_link = MagicLink.create!(identity: identities(:admin))
    email = MagicLinkMailer.sign_in_instructions(magic_link)
    log = StringIO.new
    original_logger = ActionMailer::Base.logger
    ActionMailer::Base.logger = ActiveSupport::Logger.new(log)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "admin@example.com" ], email.to
    assert_equal "Your FastRetro code is #{magic_link.code}", email.subject
    assert_match magic_link.code, email.body.encoded
    assert_includes log.string, "Delivered mail"
    assert_not_includes log.string, magic_link.code
  ensure
    ActionMailer::Base.logger = original_logger
  end
end

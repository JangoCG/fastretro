require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  test "sign_in_instructions" do
    magic_link = MagicLink.create!(identity: identities(:admin))
    email = MagicLinkMailer.sign_in_instructions(magic_link)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "admin@example.com" ], email.to
    assert_equal "Your FastRetro code is #{magic_link.code}", email.subject
    assert_match magic_link.code, email.body.encoded
  end
end

require "test_helper"

class RetroReminderMailerTest < ActionMailer::TestCase
  test "next_retro" do
    retro = retros(:one)
    retro.actions.create!(user: users(:one), status: :published, content: "Follow up with the team")

    email = RetroReminderMailer.next_retro(retro)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "one@example.com" ], email.to
    assert_equal "Review your action items and run the next retro", email.subject
    assert_match retro.name, email.body.encoded
    assert_match "1 action item", email.body.encoded
    assert_match "#{retro.account.slug}/retros/new", email.body.encoded
  end
end

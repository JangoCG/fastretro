class RetroReminderMailerPreview < ActionMailer::Preview
  def next_retro
    RetroReminderMailer.next_retro(Retro.completed_with_actions.first || Retro.first)
  end
end

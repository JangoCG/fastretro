class RetroReminderMailer < ApplicationMailer
  def next_retro(retro)
    @retro = retro
    @account = retro.account
    @action_count = retro.actions.published.count
    @new_retro_url = new_retro_url(script_name: @account.slug)

    mail to: retro.facilitator.identity.email_address, subject: "Review your action items and run the next retro"
  end
end

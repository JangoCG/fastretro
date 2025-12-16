class Admin::StatsController < AdminController
  layout "admin"

  def show
    @accounts_total = Account.count
    @accounts_last_7_days = Account.where(created_at: 7.days.ago..).count
    @accounts_last_24_hours = Account.where(created_at: 24.hours.ago..).count

    @identities_total = Identity.count
    @identities_last_7_days = Identity.where(created_at: 7.days.ago..).count
    @identities_last_24_hours = Identity.where(created_at: 24.hours.ago..).count

    @retros_total = Retro.count
    @retros_last_7_days = Retro.where(created_at: 7.days.ago..).count
    @retros_last_24_hours = Retro.where(created_at: 24.hours.ago..).count

    @feedbacks_total = Feedback.count
    @feedbacks_last_7_days = Feedback.where(created_at: 7.days.ago..).count
    @feedbacks_last_24_hours = Feedback.where(created_at: 24.hours.ago..).count

    @top_accounts = Account
      .where("feedbacks_count > 0")
      .order(feedbacks_count: :desc)
      .limit(20)

    @recent_accounts = Account.order(created_at: :desc).limit(10)
  end
end

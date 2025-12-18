class Account::BillingWaiver < ApplicationRecord
  belongs_to :account

  def subscription
    @subscription ||= Account::Subscription.new(plan_key: Plan.paid.key)
  end
end

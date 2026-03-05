module SubscriptionsHelper
  def subscription_period_end_action(subscription)
    if subscription.to_be_canceled?
      I18n.t("account.settings.subscription.ends_on")
    elsif subscription.canceled?
      I18n.t("account.settings.subscription.ended_on")
    else
      I18n.t("account.settings.subscription.next_payment", amount: format_currency(subscription.next_amount_due)).html_safe
    end
  end

  def format_currency(amount)
    number_to_currency(amount, unit: "€", format: "%u%n", precision: (amount % 1).zero? ? 0 : 2)
  end
end

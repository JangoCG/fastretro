class My::MenusController < ApplicationController
  def show
    @users = Current.account.users.active.alphabetically
    @accounts = Current.identity.accounts

    fresh_when etag: [
      @users,
      @accounts,
      Current.account,
      Current.account.subscription,
      Current.account.billing_waiver,
      FastRetro.saas?
    ]
  end
end

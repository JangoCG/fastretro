class Admin::AccountsController < AdminController
  include Admin::AccountScoped

  layout "admin"

  def edit
  end
end

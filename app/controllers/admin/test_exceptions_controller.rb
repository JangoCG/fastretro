class Admin::TestExceptionsController < AdminController
  def create
    raise "Test exception triggered from admin stats"
  end
end

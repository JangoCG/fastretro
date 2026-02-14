class ErrorsController < ApplicationController
  skip_before_action :require_authentication

  def not_found
    render status: :not_found
  end
end

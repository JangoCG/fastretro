class Users::VerificationsController < ApplicationController
  layout "public"

  def new
  end

  def create
    Current.user.verify
    redirect_to root_path, notice: t("flash.email_verified")
  end
end

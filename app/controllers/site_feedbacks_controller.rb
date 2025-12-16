class SiteFeedbacksController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to new_site_feedback_path, alert: "Too many submissions. Please try again later." }

  layout "admin"

  def new
  end

  def create
    if params[:message].blank?
      flash.now[:alert] = "Please enter a message."
      return render :new, status: :unprocessable_entity
    end

    from_email = Current.identity&.email_address || params[:email]
    from_name = Current.user&.name || params[:name] || "Anonymous"

    if from_email.blank?
      flash.now[:alert] = "Please enter your email address."
      return render :new, status: :unprocessable_entity
    end

    SiteFeedbackMailer.notify(
      message: params[:message],
      from_email: from_email,
      from_name: from_name
    ).deliver_later

    redirect_to new_site_feedback_path, notice: "Thanks for your feedback! We'll get back to you soon."
  end
end

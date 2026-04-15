class SessionsController < ApplicationController
  disallow_account_scope
  require_unauthenticated_access except: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: :rate_limit_exceeded

  layout "auth"

  def new
  end

  def create
    if identity = Identity.find_by_email_address(email_address)
      sign_in identity
    elsif Account.accepting_signups?
      sign_up
    else
      redirect_to_fake_session_magic_link email_address
    end
  end

  def destroy
    terminate_session
    redirect_to_logout_url
  end

  private
    def sign_in(identity)
      redirect_to_session_magic_link identity.send_magic_link
    end

    def sign_up
      signup = Signup.new(email_address: email_address)

      if signup.valid?(:identity_creation)
        magic_link = signup.create_identity
        redirect_to_session_magic_link magic_link
      else
        head :unprocessable_entity
      end
    end

    def email_address
      params.expect(:email_address)
    end

    def rate_limit_exceeded
      redirect_to new_session_path, alert: t("flash.try_again_later")
    end
end

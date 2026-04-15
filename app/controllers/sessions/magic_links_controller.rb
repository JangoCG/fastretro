class Sessions::MagicLinksController < ApplicationController
  disallow_account_scope
  require_unauthenticated_access
  rate_limit to: 10, within: 15.minutes, only: :create, with: :rate_limit_exceeded
  rate_limit to: 5, within: 5.minutes, only: :resend, with: :resend_rate_limit_exceeded
  before_action :ensure_that_email_address_pending_authentication_exists

  layout "auth"

  def show
  end

  def resend
    if identity = Identity.find_by_email_address(email_address_pending_authentication)
      redirect_to_session_magic_link identity.send_magic_link
      flash[:notice] = t("flash.new_code_sent")
    else
      redirect_to new_session_path, alert: t("flash.enter_email_again")
    end
  end

  def create
    if magic_link = MagicLink.consume(code)
      authenticate magic_link
    else
      invalid_code
    end
  end

  private
    def ensure_that_email_address_pending_authentication_exists
      unless email_address_pending_authentication.present?
        redirect_to new_session_path, alert: t("flash.enter_email_to_sign_in")
      end
    end

    def authenticate(magic_link)
      if ActiveSupport::SecurityUtils.secure_compare(email_address_pending_authentication || "", magic_link.identity.email_address)
        sign_in magic_link
      else
        email_address_mismatch
      end
    end

    def sign_in(magic_link)
      clear_pending_authentication_token
      start_new_session_for magic_link.identity
      redirect_to after_sign_in_url(magic_link)
    end

    def email_address_mismatch
      clear_pending_authentication_token
      redirect_to new_session_path, alert: t("flash.auth_failed")
    end

    def invalid_code
      redirect_to session_magic_link_path, flash: { shake: true }
    end

    def code
      params.expect(:code)
    end

    def after_sign_in_url(magic_link)
      if magic_link.for_sign_up?
        new_signup_completion_path
      else
        after_authentication_url
      end
    end

    def rate_limit_exceeded
      redirect_to session_magic_link_path, alert: t("flash.rate_limit_15min")
    end

    def resend_rate_limit_exceeded
      redirect_to session_magic_link_path, alert: t("flash.too_many_resends")
    end
end

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_account # Checking and setting account must happen first
    before_action :require_authentication
    after_action :ensure_development_magic_link_not_leaked
    helper_method :authenticated?
    helper_method :email_address_pending_authentication

    etag { Current.identity.id if authenticated? }

    include LoginHelper
  end

  class_methods do
    def require_unauthenticated_access(**options)
      allow_unauthenticated_access **options
      before_action :redirect_authenticated_user, **options
    end

    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :resume_session, **options
      allow_unauthorized_access **options
    end

    def disallow_account_scope(**options)
      skip_before_action :require_account, **options
      before_action :redirect_tenanted_request, **options
    end
  end

  private
    def authenticated?
      Current.identity.present?
    end

    def require_account
      unless Current.account.present?
        redirect_to main_app.session_menu_url(script_name: nil)
      end
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      if session = find_session_by_cookie
        set_current_session session
      end
    end

    def find_session_by_cookie
      Session.find_signed(cookies.signed[:session_token])
    end

    def request_authentication
      if Current.account.present?
        session[:return_to_after_authenticating] = request.url
      end

      redirect_to_login_url
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || main_app.session_menu_url(script_name: nil)
    end

    def redirect_authenticated_user
      if authenticated?
        redirect_to Current.account.present? ? main_app.root_url : main_app.session_menu_url(script_name: nil)
      end
    end

    def redirect_tenanted_request
      redirect_to main_app.retros_url if Current.account.present?
    end

    def start_new_session_for(identity)
      identity.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        set_current_session session
        verify_users_for(identity)
      end
    end

    def verify_users_for(identity)
      identity.users.where(verified_at: nil).update_all(verified_at: Time.current)
    end

    def set_current_session(session)
      Current.session = session
      cookies.signed.permanent[:session_token] = { value: session.signed_id, httponly: true, same_site: :lax }
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_token)
    end

    def ensure_development_magic_link_not_leaked
      unless Rails.env.development?
        raise "Leaking magic link via flash in #{Rails.env}?" if flash[:magic_link_code].present?
      end
    end

    def email_address_pending_authentication_matches?(email_address)
      if ActiveSupport::SecurityUtils.secure_compare(email_address, email_address_pending_authentication || "")
        session.delete(:email_address_pending_authentication)
        true
      else
        false
      end
    end

    def email_address_pending_authentication
      session[:email_address_pending_authentication]
    end

    def redirect_to_session_magic_link(magic_link, return_to: nil)
      serve_development_magic_link(magic_link)
      session[:email_address_pending_authentication] = magic_link.identity.email_address if magic_link
      session[:return_to_after_authenticating] = return_to if return_to
      redirect_to main_app.session_magic_link_url(script_name: nil)
    end

    def serve_development_magic_link(magic_link)
      if Rails.env.development?
        flash[:magic_link_code] = magic_link&.code
      end
    end
end

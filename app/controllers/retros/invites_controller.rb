class Retros::InvitesController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { head :too_many_requests }

  before_action :set_join_code
  before_action :set_retro
  before_action :set_identity, only: :create

  layout "auth"

  def show
    if authenticated? && already_member?
      # Already in this account - go straight to the retro
      redirect_to retro_path(@retro, script_name: @join_code.account.slug)
    elsif authenticated?
      # Authenticated but not a member - join the account via join code
      join_account_and_redirect
    end
    # Otherwise, render the form
  end

  def create
    @join_code.redeem_if { |account| @identity.join(account) }
    user = User.active.find_by!(account: @join_code.account, identity: @identity)

    # Add as retro participant
    @retro.add_participant(user)

    if @identity == Current.identity && user.setup?
      # Already logged in as this identity and user is set up
      redirect_to retro_path(@retro, script_name: @join_code.account.slug)
    elsif @identity == Current.identity
      # Logged in but needs to complete setup
      redirect_to new_users_verification_url(script_name: @join_code.account.slug)
    else
      # Different identity or not logged in - send magic link
      terminate_session if Current.identity

      redirect_to_session_magic_link \
        @identity.send_magic_link,
        return_to: retro_url(@retro, script_name: @join_code.account.slug)
    end
  end

  private

  def set_join_code
    @join_code = Account::JoinCode.find_by(code: params[:code])

    if @join_code.nil?
      redirect_to new_session_path(script_name: nil), alert: "Invalid invite link."
    elsif !@join_code.active?
      redirect_to new_session_path(script_name: nil), alert: "This invite link has expired."
    end
  end

  def set_retro
    return unless @join_code

    @retro = @join_code.account.retros.find_by(id: params[:retro_id])

    if @retro.nil?
      redirect_to new_session_path(script_name: nil), alert: "Retro not found."
    end
  end

  def set_identity
    @identity = Identity.find_or_initialize_by(email_address: params.expect(:email_address))

    if @identity.new_record?
      if @identity.invalid?
        head :unprocessable_entity
      else
        @identity.save!
      end
    end
  end

  def already_member?
    Current.identity.users.exists?(account: @join_code.account)
  end

  def join_account_and_redirect
    @join_code.redeem_if { |account| Current.identity.join(account) }

    user = User.find_by(account: @join_code.account, identity: Current.identity)
    @retro.add_participant(user) if user

    redirect_to retro_path(@retro, script_name: @join_code.account.slug),
                notice: "Welcome! You've joined #{@join_code.account.name}."
  end
end

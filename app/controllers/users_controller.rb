class UsersController < ApplicationController
  before_action :set_user
  before_action :ensure_permission_to_administer_user, only: :destroy

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to @user }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.deactivate
    redirect_to account_settings_path, notice: "#{@user.name} has been removed from this account"
  end

  private
    def set_user
      @user = Current.account.users.find(params[:id])
    end

    def ensure_permission_to_administer_user
      head :forbidden unless Current.user.can_administer?(@user)
    end

    def user_params
      params.require(:user).permit(:name)
    end
end

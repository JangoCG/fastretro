class ActionsController < ApplicationController
  before_action :set_retro
  before_action :set_action, only: %i[ show edit update destroy ]
  before_action :authorize_author!, only: %i[ edit update destroy ]

  def new
    @action = @retro.actions.find_or_create_by!(
      user: Current.user,
      status: :drafted
    )
  end

  def create
    @action = @retro.actions.find_or_create_by!(
      user: Current.user,
      status: :drafted
    )
    redirect_to new_retro_action_path(@retro)
  end

  def show
  end

  def edit
  end

  def update
    @action.update!(action_params)
    head :ok
  end

  def destroy
    @action.destroy!
    redirect_to @retro, notice: "Action deleted"
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def set_action
      @action = @retro.actions.find(params[:id])
    end

    def authorize_author!
      unless @action.user == Current.user
        redirect_to @retro, alert: "You can only edit your own actions"
      end
    end

    def action_params
      params.require(:retro_action).permit(:content)
    end
end

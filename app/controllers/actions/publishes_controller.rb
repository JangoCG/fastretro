class Actions::PublishesController < ApplicationController
  before_action :set_retro
  before_action :set_action

  def create
    @action.update!(content: params[:content]) if params[:content].present?
    @action.publish

    if params[:creation_type] == "add_another"
      new_action = @retro.actions.create!(
        user: Current.user,
        status: :drafted
      )
      redirect_to retro_action_path(@retro, new_action)
    else
      redirect_to @retro
    end
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def set_action
      @action = @retro.actions.find(params[:action_id])
    end
end

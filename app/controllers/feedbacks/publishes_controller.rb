class Feedbacks::PublishesController < ApplicationController
  before_action :set_retro
  before_action :set_feedback

  def create
    @feedback.update!(content: params[:content]) if params[:content].present?
    @feedback.publish

    if params[:creation_type] == "add_another"
      redirect_to new_retro_feedback_path(@retro, category: @feedback.category)
    else
      redirect_to @retro
    end
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def set_feedback
      @feedback = @retro.feedbacks.find(params[:feedback_id])
    end
end

class FeedbacksController < ApplicationController
  before_action :set_retro
  before_action :set_feedback, only: %i[ show edit update destroy ]
  before_action :authorize_author!, only: %i[ edit update destroy ]

  def new
    @feedback = @retro.feedbacks.find_or_create_by!(
      user: Current.user,
      category: params[:category],
      status: :drafted
    )
  end

  def create
    @feedback = @retro.feedbacks.find_or_create_by!(
      user: Current.user,
      category: params[:category],
      status: :drafted
    )
    redirect_to new_retro_feedback_path(@retro, category: params[:category])
  end

  def show
  end

  def edit
  end

  def update
    @feedback.update!(feedback_params)
    head :ok
  end

  def destroy
    @feedback.destroy!
    redirect_to @retro, notice: "Feedback deleted"
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def set_feedback
      @feedback = @retro.feedbacks.find(params[:id])
    end

    def authorize_author!
      unless @feedback.user == Current.user
        redirect_to @retro, alert: "You can only edit your own feedback"
      end
    end

    def feedback_params
      params.require(:feedback).permit(:content)
    end
end

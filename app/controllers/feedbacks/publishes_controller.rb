class Feedbacks::PublishesController < ApplicationController
  before_action :set_retro
  before_action :set_feedback

  rescue_from Feedback::Statuses::LimitReached, with: :handle_limit_reached

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

    def handle_limit_reached
      if Current.user&.owner? || Current.user&.admin?
        redirect_to account_settings_path(anchor: "subscription"),
          alert: "You've used all #{Plan.free.feedback_limit} free feedbacks. Please upgrade to continue."
      else
        redirect_to @retro,
          alert: "The account has reached its feedback limit. Please contact an account admin."
      end
    end
end

class Feedbacks::CategoriesController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :set_feedback
  before_action :ensure_category_movement_allowed

  def update
    if @feedback.feedback_group_id?
      @feedback.errors.add(:category, "cannot change while grouped")
      render json: { errors: @feedback.errors.full_messages }, status: :unprocessable_entity
    else
      @feedback.update!(category: params.expect(:category))
      head :no_content
    end
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end

    def set_feedback
      @feedback = @retro.feedbacks.published.find(params[:feedback_id])
    end

    def ensure_category_movement_allowed
      allowed = if @retro.grouping?
        @retro.admin?(Current.user)
      elsif @retro.brainstorming?
        @feedback.user == Current.user
      else
        false
      end

      raise RetroAuthorization::RetroNotFoundError unless allowed
    end
end

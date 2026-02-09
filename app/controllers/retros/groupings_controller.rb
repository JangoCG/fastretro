class Retros::GroupingsController < ApplicationController
  include RetroAuthorization

  layout "retro"

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :set_current_participant

  def show
    @feedbacks_by_category = @retro.feedbacks.published
      .includes(:user, :rich_text_content, :feedback_group)
      .to_a
      .group_by(&:category)
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def set_current_participant
    @current_participant = @retro.participants.find_by(user: Current.user)
  end
end

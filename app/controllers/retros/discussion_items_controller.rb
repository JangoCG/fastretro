class Retros::DiscussionItemsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :ensure_retro_admin
  before_action :ensure_discussion_phase
  before_action :set_item

  def update
    @item.update!(discussed: ActiveModel::Type::Boolean.new.cast(params[:discussed]))
    head :ok
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def ensure_discussion_phase
    return if @retro.discussion?

    redirect_to retro_path(@retro), alert: "Items can only be marked discussed during discussion phase"
  end

  def set_item
    @item = case params[:item_type]
    when "Feedback"
      @retro.feedbacks.published.find(params[:item_id])
    when "FeedbackGroup"
      @retro.feedback_groups
        .joins(:feedbacks)
        .merge(@retro.feedbacks.published)
        .distinct
        .find(params[:item_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end

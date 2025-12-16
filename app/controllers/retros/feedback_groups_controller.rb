class Retros::FeedbackGroupsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_participant
  before_action :ensure_retro_admin
  before_action :ensure_grouping_phase

  def create
    source_feedback = @retro.feedbacks.find(params[:source_feedback_id])
    target_id = params[:target_feedback_id].to_s

    # Check if target is a group (format: "group-123") or a feedback
    if target_id.start_with?("group-")
      group_id = target_id.sub("group-", "")
      group = @retro.feedback_groups.find(group_id)
    else
      target_feedback = @retro.feedbacks.find(target_id)
      group = find_or_create_group(source_feedback, target_feedback)
      target_feedback.update!(feedback_group: group) unless target_feedback.feedback_group == group
    end

    source_feedback.update!(feedback_group: group)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to retro_grouping_path(@retro) }
    end
  end

  def destroy
    group = @retro.feedback_groups.find(params[:id])

    # Ungroup all feedbacks in this group
    group.feedbacks.update_all(feedback_group_id: nil)

    # Delete the now-empty group
    group.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to retro_grouping_path(@retro) }
    end
  end

  def remove_feedback
    feedback = @retro.feedbacks.find(params[:feedback_id])
    group = feedback.feedback_group

    feedback.update!(feedback_group: nil)

    # Clean up group if it has less than 2 feedbacks remaining
    if group.present? && group.feedbacks.count < 2
      group.feedbacks.update_all(feedback_group_id: nil)
      group.destroy
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to retro_grouping_path(@retro) }
    end
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def ensure_grouping_phase
    unless @retro.grouping?
      redirect_to @retro, alert: "Grouping is only available during the grouping phase"
    end
  end

  def find_or_create_group(source_feedback, target_feedback)
    # If either feedback already has a group, use that
    return target_feedback.feedback_group if target_feedback.feedback_group.present?
    return source_feedback.feedback_group if source_feedback.feedback_group.present?

    # Create a new group
    @retro.feedback_groups.create!
  end
end

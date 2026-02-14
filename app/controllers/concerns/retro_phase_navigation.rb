module RetroPhaseNavigation
  extend ActiveSupport::Concern

  private

  def phase_path_for(retro)
    case retro.phase.to_sym
    when :waiting_room then retro_waiting_room_path(retro)
    when :action_review then retro_action_review_path(retro)
    when :brainstorming then retro_brainstorming_path(retro)
    when :grouping then retro_grouping_path(retro)
    when :voting then retro_voting_path(retro)
    when :discussion then retro_discussion_path(retro)
    when :complete then retro_complete_path(retro)
    else retro_path(retro)
    end
  end

  def broadcast_phase_redirect(url = nil)
    url ||= phase_path_for(@retro)

    stream_content = %(<turbo-stream action="redirect" url="#{url}"></turbo-stream>)
    participant_users = @retro.users
    participant_users = participant_users.where.not(id: Current.user.id) if Current.user.present?

    participant_users.find_each do |user|
      Turbo::StreamsChannel.broadcast_stream_to(
        [ @retro, user ],
        content: stream_content
      )
    end
  end
end

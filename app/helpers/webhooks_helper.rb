module WebhooksHelper
  ACTION_LABELS = {
    "retro.created" => "Retro created",
    "retro.started" => "Retro started",
    "retro.phase_changed" => "Retro phase changed",
    "retro.completed" => "Retro completed",
    "feedback.published" => "Feedback published",
    "feedback.deleted" => "Feedback deleted",
    "action.published" => "Action published",
    "action.completed" => "Action completed",
    "action.deleted" => "Action deleted",
    "participant.joined" => "Participant joined"
  }.freeze

  def webhook_action_options(actions = Webhook::PERMITTED_ACTIONS)
    ACTION_LABELS.select { |key, _| actions.include?(key.to_s) }
  end

  def webhook_action_label(action)
    ACTION_LABELS[action] || action.to_s.humanize
  end
end

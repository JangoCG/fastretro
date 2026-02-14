module RetrosHelper
  PHASE_INSTRUCTIONS = {
    "waiting_room" => "Invite teammates and wait until everyone joins.",
    "action_review" => "Review previous action items and mark completed ones.",
    "brainstorming" => "Add your feedback ideas to the board.",
    "grouping" => "Group similar feedback items into clusters.",
    "voting" => "Vote for the feedback that matters most.",
    "discussion" => "Discuss top-voted items and define clear action items.",
    "complete" => "Review outcomes and export the retro summary."
  }.freeze

  def retro_phase_instruction(phase)
    PHASE_INSTRUCTIONS.fetch(phase.to_s, "Collaborate with your team in this phase.")
  end
end

class WaitingParticipantCardComponent < ApplicationComponent
  AVATAR_COLORS = %w[
    bg-blue-500
    bg-emerald-500
    bg-purple-500
    bg-amber-500
    bg-rose-500
    bg-cyan-500
  ].freeze

  def initialize(participant:, index: 0, role_controls: false)
    @participant = participant
    @index = index
    @role_controls = role_controls
  end

  def avatar_color
    AVATAR_COLORS[@index % AVATAR_COLORS.size]
  end

  def role_label
    @participant.admin? ? "MODERATOR" : "PARTICIPANT"
  end

  def role_controls?
    @role_controls
  end

  def role_toggle_label
    @participant.admin? ? t("components.participant_roles.demote") : t("components.participant_roles.promote")
  end

  def toggled_role
    @participant.admin? ? "participant" : "admin"
  end

  def role_path
    retro_participant_role_path(@participant.retro, @participant, script_name: @participant.retro.account.slug)
  end
end

class WaitingParticipantCardComponent < ApplicationComponent
  AVATAR_COLORS = %w[
    bg-blue-500
    bg-emerald-500
    bg-purple-500
    bg-amber-500
    bg-rose-500
    bg-cyan-500
  ].freeze

  def initialize(participant:, index: 0)
    @participant = participant
    @index = index
  end

  def avatar_color
    AVATAR_COLORS[@index % AVATAR_COLORS.size]
  end

  def role_label
    @participant.admin? ? "MODERATOR" : "PARTICIPANT"
  end
end

class ParticipantListComponent < ApplicationComponent
  AVATAR_COLORS = %w[
    bg-blue-500
    bg-emerald-500
    bg-purple-500
    bg-amber-500
    bg-rose-500
    bg-cyan-500
  ].freeze

  STATUS_INDICATOR = {
    online: "bg-emerald-500",
    away: "bg-amber-500",
    offline: "bg-gray-400"
  }.freeze

  def initialize(retro:, highlight_enabled: false)
    @retro = retro
    @highlight_enabled = highlight_enabled
  end

  def highlight_enabled?
    @highlight_enabled
  end

  def highlighted?(participant)
    @retro.highlighted_user_id == participant.user_id
  end

  def highlighting_active?
    @retro.highlighted_user_id.present?
  end

  def participants
    @participants ||= begin
      records = @retro.participants.order(:created_at).to_a
      ActiveRecord::Associations::Preloader.new(records: records, associations: :user).call
      records
    end
  end

  def avatar_color(index)
    AVATAR_COLORS[index % AVATAR_COLORS.size]
  end

  def status_color(status)
    STATUS_INDICATOR[status]
  end

  def role_badge(participant)
    participant.admin? ? "MODERATOR" : "MEMBER"
  end

  def status_text(participant)
    if participant.finished?
      "#{role_badge(participant)} // FINISHED"
    else
      "#{role_badge(participant)} // ONLINE"
    end
  end
end

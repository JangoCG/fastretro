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

  def initialize(retro:, highlight_enabled: false, participants: nil)
    @retro = retro
    @highlight_enabled = highlight_enabled
    @preloaded_participants = participants
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
    return @preloaded_participants if @preloaded_participants

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

  def role_controls?(participant)
    role_management_enabled? && !(participant.admin? && admin_count == 1)
  end

  def role_toggle_label(participant)
    participant.admin? ? t("components.participant_roles.demote_short") : t("components.participant_roles.promote_short")
  end

  def role_toggle_title(participant)
    participant.admin? ? t("components.participant_roles.demote") : t("components.participant_roles.promote")
  end

  def toggled_role(participant)
    participant.admin? ? "participant" : "admin"
  end

  def role_path(participant)
    retro_participant_role_path(@retro, participant, script_name: @retro.account.slug)
  end

  def status_text(participant)
    if participant.finished?
      "#{role_badge(participant)} // #{I18n.t('participant_status.finished')}"
    else
      "#{role_badge(participant)} // #{I18n.t('participant_status.online')}"
    end
  end

  private
    def role_management_enabled?
      Current.user.present? && @retro.admin?(Current.user)
    end

    def admin_count
      @admin_count ||= participants.count(&:admin?)
    end
end

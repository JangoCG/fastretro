class ParticipantRoleButtonComponent < ApplicationComponent
  BASE_CLASSES = "bg-white text-zinc-900 font-bold uppercase tracking-widest border-[1.5px] border-zinc-900 hover:bg-[#ffe600] transition-colors cursor-pointer".freeze
  COMPACT_CLASSES = "text-[0.6rem] font-mono px-2 py-1.5".freeze
  CARD_CLASSES = "mt-2 inline-block text-[0.5rem] px-2.5 py-1.5".freeze

  def initialize(participant:, manageable:, admin_count:, compact: false)
    @participant = participant
    @manageable = manageable
    @admin_count = admin_count
    @compact = compact
  end

  def render?
    @manageable && !(@participant.admin? && @admin_count == 1)
  end

  def label
    @compact ? t("components.participant_roles.#{toggle_action}_short") : t("components.participant_roles.#{toggle_action}")
  end

  def title
    t("components.participant_roles.#{toggle_action}")
  end

  def toggled_role
    @participant.admin? ? "participant" : "admin"
  end

  def role_path
    retro_participant_role_path(@participant.retro, @participant, script_name: @participant.retro.account.slug)
  end

  def button_classes
    class_names(BASE_CLASSES, @compact ? COMPACT_CLASSES : CARD_CLASSES)
  end

  private
    def toggle_action
      @participant.admin? ? "demote" : "promote"
    end
end

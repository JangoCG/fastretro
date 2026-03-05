module RetrosHelper
  def retro_phase_instruction(phase)
    I18n.t("phase_instructions.#{phase}", default: I18n.t("phase_instructions.default"))
  end
end

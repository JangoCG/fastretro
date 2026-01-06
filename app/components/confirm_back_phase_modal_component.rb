class ConfirmBackPhaseModalComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  private

  def previous_phase_name
    @retro.previous_phase&.to_s&.tr("_", " ")&.upcase || "PREVIOUS PHASE"
  end
end

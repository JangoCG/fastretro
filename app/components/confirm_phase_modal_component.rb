class ConfirmPhaseModalComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  private

  def next_phase_name
    @retro.next_phase&.to_s&.tr("_", " ")&.upcase || "NEXT PHASE"
  end
end

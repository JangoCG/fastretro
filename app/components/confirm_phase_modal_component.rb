class ConfirmPhaseModalComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  private

  def next_phase_name
    if next_phase = @retro.next_phase
      I18n.t("phases.#{next_phase}").upcase
    else
      I18n.t("phases.complete").upcase
    end
  end
end

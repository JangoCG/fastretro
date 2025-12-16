class ConfirmPhaseModalComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  private

  def next_phase_name
    @retro.next_phase&.to_s&.tr("_", " ")&.upcase || "NEXT PHASE"
  end

  def unfinished_count
    @retro.participants.where(finished: false).count
  end

  def all_finished?
    unfinished_count.zero?
  end
end

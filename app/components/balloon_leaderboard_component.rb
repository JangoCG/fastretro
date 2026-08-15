class BalloonLeaderboardComponent < ApplicationComponent
  MEDALS = %w[🥇 🥈 🥉].freeze

  def initialize(retro:)
    @retro = retro
  end

  def dom_id
    "balloon-leaderboard"
  end

  def leaders
    @leaders ||= @retro.balloon_leaderboard.to_a
  end

  def any_pops?
    leaders.any?
  end

  def rank_badge(index)
    MEDALS[index] || "##{index + 1}"
  end

  def total_pops
    leaders.sum(&:balloons_popped)
  end
end

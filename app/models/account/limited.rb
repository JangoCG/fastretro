module Account::Limited
  extend ActiveSupport::Concern

  NEAR_RETRO_LIMIT_THRESHOLD = 3

  def nearing_plan_retros_limit?
    return false unless plan.limit_retros?

    remaining_retros_count < NEAR_RETRO_LIMIT_THRESHOLD
  end

  def exceeding_retro_limit?
    return false if comped?
    return false unless plan.limit_retros?

    retros_count >= plan.retro_limit
  end

  private
    def remaining_retros_count
      plan.retro_limit - retros_count
    end
end

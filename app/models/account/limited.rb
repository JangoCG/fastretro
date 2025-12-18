module Account::Limited
  extend ActiveSupport::Concern

  NEAR_FEEDBACK_LIMIT_THRESHOLD = 3

  def nearing_plan_feedbacks_limit?
    return false unless plan.limit_feedbacks?

    remaining_feedbacks_count < NEAR_FEEDBACK_LIMIT_THRESHOLD
  end

  def exceeding_feedback_limit?
    return false if comped?
    return false unless plan.limit_feedbacks?

    feedbacks_count >= plan.feedback_limit
  end

  private
    def remaining_feedbacks_count
      plan.feedback_limit - feedbacks_count
    end
end

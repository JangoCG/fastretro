class LandingPageFooterComponent < ApplicationComponent
  def free_limit
    Plan.free.feedback_limit
  end
end

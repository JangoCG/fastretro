class LandingPageFooterComponent < ApplicationComponent
  def free_limit
    Identity::FREE_FEEDBACK_LIMIT
  end
end

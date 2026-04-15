class LandingPageFooterComponent < ApplicationComponent
  def free_limit
    Plan.free.retro_limit
  end
end

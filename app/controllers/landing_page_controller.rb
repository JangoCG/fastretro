class LandingPageController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  layout "public"

  # Retro count from the Laravel version before migrating to Rails
  LEGACY_RETRO_COUNT = 1124

  def show
    @free_limit = Identity::FREE_FEEDBACK_LIMIT
    @retro_count = Rails.cache.fetch("retro_count", expires_in: 4.hours) do
      Retro.count + LEGACY_RETRO_COUNT
    end
  end
end

class ApplicationComponent < ViewComponent::Base
  delegate :icon_tag, to: :helpers
end

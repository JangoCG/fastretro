class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include CurrentRequest

  stale_when_importmap_changes
  allow_browser versions: :modern
end

class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include CurrentRequest

  before_action :set_log_context

  stale_when_importmap_changes
  allow_browser versions: :modern

  private
    def set_log_context
      if Current.identity.present?
        logger.push_tags("identity:#{Current.identity.id}")
      end

      if Current.account.present?
        logger.push_tags("account:#{Current.account.external_account_id}")
      end
    end
end

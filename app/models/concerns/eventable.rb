module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  def record_event(action, creator: Current.user, particulars: {})
    events.create!(
      account: event_account,
      retro: event_retro,
      action: action,
      creator: creator,
      particulars: particulars
    )
  end

  private
    def event_account
      respond_to?(:account) ? account : retro.account
    end

    def event_retro
      respond_to?(:retro) ? retro : self
    end
end

module Retro::Limited
  extend ActiveSupport::Concern

  included do
    after_create :increment_account_retros_count, if: -> { FastRetro.saas? }
  end

  private
    def increment_account_retros_count
      account.increment!(:retros_count)
    end
end

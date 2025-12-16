class User < ApplicationRecord
  include Role
  include EmailAddressChangeable

  belongs_to :account
  belongs_to :identity, optional: true

  scope :alphabetically, -> { order(:name) }

  def deactivate
    update!(active: false, identity: nil)
  end

  def setup?
    name != identity.email_address
  end

  def verified?
    verified_at.present?
  end

  def verify
    update!(verified_at: Time.current) unless verified?
  end

  def initials
    name.to_s.split.map(&:first).join.upcase.first(2)
  end
end

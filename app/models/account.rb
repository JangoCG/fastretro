class Account < ApplicationRecord
  include Account::MultiTenantable
  include Account::Billing
  include Account::Limited

  has_one :join_code, class_name: "Account::JoinCode", dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :retros, dependent: :destroy
  has_many :feedbacks, through: :retros
  has_many :webhooks, dependent: :destroy
  has_many :events, dependent: :destroy

  before_create :assign_external_account_id
  after_create :create_join_code

  validates :name, presence: true

  class << self
    def create_with_owner(account:, owner:)
      create!(**account).tap do |account|
        account.users.create!(**owner.reverse_merge(role: "owner", verified_at: Time.current))
      end
    end
  end

  has_one :owner_user, -> { where(role: "owner") }, class_name: "User"
  has_one :owner_identity, through: :owner_user, source: :identity

  def slug
    "/#{AccountSlug.encode(external_account_id)}"
  end

  def account
    self
  end

  def has_completed_retros_with_actions?
    retros.completed_with_actions.exists?
  end

  private
    def assign_external_account_id
      self.external_account_id ||= ExternalIdSequence.next
    end
end

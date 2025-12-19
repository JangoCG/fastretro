class Webhook < ApplicationRecord
  include Webhook::Triggerable

  PERMITTED_SCHEMES = %w[ http https ].freeze
  PERMITTED_ACTIONS = %w[
    retro.created
    retro.started
    retro.phase_changed
    retro.completed
    feedback.published
    feedback.deleted
    action.published
    action.completed
    action.deleted
    participant.joined
  ].freeze

  has_secure_token :signing_secret

  belongs_to :account
  has_many :deliveries, class_name: "Webhook::Delivery", dependent: :delete_all
  has_one :delinquency_tracker, class_name: "Webhook::DelinquencyTracker", dependent: :delete

  serialize :subscribed_actions, type: Array, coder: JSON

  scope :ordered, -> { order(name: :asc, id: :desc) }
  scope :active, -> { where(active: true) }

  after_create :create_delinquency_tracker!

  normalizes :subscribed_actions, with: ->(value) { Array.wrap(value).map(&:to_s).uniq & PERMITTED_ACTIONS }

  validates :name, presence: true
  validate :validate_url

  def activate
    update!(active: true) unless active?
    delinquency_tracker&.reset!
  end

  def deactivate
    update!(active: false)
  end

  private
    def validate_url
      uri = URI.parse(url.presence)

      if PERMITTED_SCHEMES.exclude?(uri.scheme)
        errors.add :url, "must use http or https"
      end
    rescue URI::InvalidURIError
      errors.add :url, "is not a valid URL"
    end
end

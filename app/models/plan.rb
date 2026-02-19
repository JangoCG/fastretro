class Plan
  PLANS = {
    free_v1: {
      name: "Free",
      price: 0,
      feedback_limit: ENV.fetch("FREE_FEEDBACK_LIMIT", 10).to_i,
      stripe_price_id: nil
    },
    monthly_v1: {
      name: "Paid",
      price: 9.99,
      feedback_limit: Float::INFINITY,
      stripe_price_id: ENV["STRIPE_MONTHLY_V1_PRICE_ID"]
    }
  }

  attr_reader :key, :name, :price, :feedback_limit, :stripe_price_id

  class << self
    def all
      @all ||= PLANS.map { |key, properties| new(key: key, **properties) }
    end

    def free
      @free ||= find(:free_v1)
    end

    def paid
      @paid ||= find(:monthly_v1)
    end

    def find(key)
      @all_by_key ||= all.index_by(&:key).with_indifferent_access
      @all_by_key[key]
    end

    def find_by_price_id(price_id)
      all.find { |plan| plan.stripe_price_id == price_id }
    end

    alias [] find
  end

  def initialize(key:, name:, price:, feedback_limit:, stripe_price_id: nil)
    @key = key
    @name = name
    @price = price
    @feedback_limit = feedback_limit
    @stripe_price_id = stripe_price_id
  end

  def free?
    price.zero?
  end

  def paid?
    !free?
  end

  def limit_feedbacks?
    feedback_limit != Float::INFINITY
  end
end

module AccountTenanted
  extend ActiveSupport::Concern

  ACCOUNT_KEY = "account"

  prepended do
    attr_reader :account
    around_perform :with_account_context
  end

  def initialize(...)
    super
    @account = Current.account
  end

  def serialize
    super.merge(ACCOUNT_KEY => @account&.to_gid)
  end

  def deserialize(job_data)
    super
    @account = nil
    @account_gid = job_data[ACCOUNT_KEY]
  end

  private
    def with_account_context(&block)
      resolve_account!

      if account.present?
        Current.with_account(account, &block)
      else
        yield
      end
    end

    def resolve_account!
      return unless @account_gid

      located = GlobalID::Locator.locate(@account_gid)
      raise ActiveRecord::RecordNotFound, "Account not found for #{@account_gid}" unless located.is_a?(Account)

      @account = located
    rescue ActiveRecord::RecordNotFound
      raise ActiveJob::DeserializationError
    end
end

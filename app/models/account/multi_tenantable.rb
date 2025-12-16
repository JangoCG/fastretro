module Account::MultiTenantable
  extend ActiveSupport::Concern

  class_methods do
    # Checks if multi-tenant mode is enabled.
    # Uses dynamic lookup to survive class reloading in development.
    #
    # @return [Boolean] true if multi-tenant mode is enabled
    def multi_tenant?
      return @multi_tenant if defined?(@multi_tenant) && !@multi_tenant.nil?

      @multi_tenant = (
        ENV["MULTI_TENANT"] == "true" ||
        File.exist?(Rails.root.join("tmp/multi_tenant.txt")) ||
        Rails.application.config.x.multi_tenant&.enabled == true
      )
    end

    # Alias for backwards compatibility with existing code
    def multi_tenant
      multi_tenant?
    end

    # Setter for testing purposes
    def multi_tenant=(value)
      @multi_tenant = value
    end

    # Reset cached value (useful for testing)
    def reset_multi_tenant!
      @multi_tenant = nil
    end

    def accepting_signups?
      multi_tenant? || Account.none?
    end
  end
end

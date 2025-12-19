ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    parallelize workers: :number_of_processors

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Map fixtures to namespaced models
    set_fixture_class webhook_deliveries: "Webhook::Delivery"
    set_fixture_class webhook_delinquency_trackers: "Webhook::DelinquencyTracker"

    include ActiveJob::TestHelper
    include SessionTestHelper

    setup do
      Current.account = accounts(:one)
    end

    teardown do
      Current.clear_all
    end
  end
end

class ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    integration_session.default_url_options[:script_name] = "/#{accounts(:one).external_account_id}"
  end

  private
    # Temporarily set ENV variables for a test block
    def with_env(env_vars)
      original_values = env_vars.keys.to_h { |key| [ key, ENV[key] ] }
      env_vars.each { |key, value| ENV[key] = value }
      yield
    ensure
      original_values.each { |key, value| ENV[key] = value }
    end

    def without_action_dispatch_exception_handling
      original = Rails.application.config.action_dispatch.show_exceptions
      Rails.application.config.action_dispatch.show_exceptions = :none
      Rails.application.instance_variable_set(:@app_env_config, nil) # Clear memoized env_config
      yield
    ensure
      Rails.application.config.action_dispatch.show_exceptions = original
      Rails.application.instance_variable_set(:@app_env_config, nil) # Reset env_config
    end

    def assert_in_body(text)
      assert_includes response.body, text
    end
end

class ActionDispatch::SystemTestCase
  setup do
    self.default_url_options[:script_name] = "/#{accounts(:one).external_account_id}"
  end
end

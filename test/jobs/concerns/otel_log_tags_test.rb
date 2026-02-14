require "test_helper"

class OtelLogTagsTest < ActiveSupport::TestCase
  class RaisesNameErrorJob < ApplicationJob
    def perform
      raise NameError, "job boom"
    end
  end

  class SuccessfulJob < ApplicationJob
    cattr_accessor :performed, default: false

    def perform
      self.class.performed = true
    end
  end

  test "does not swallow name error from perform when tracing is disabled" do
    assert_nil defined?(OpenTelemetry::Trace)

    assert_raises(NameError) do
      RaisesNameErrorJob.perform_now
    end
  end

  test "runs job normally when tracing is disabled" do
    assert_nil defined?(OpenTelemetry::Trace)
    SuccessfulJob.performed = false

    SuccessfulJob.perform_now

    assert SuccessfulJob.performed
  end
end

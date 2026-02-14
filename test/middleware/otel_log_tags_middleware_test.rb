require "test_helper"

class OtelLogTagsMiddlewareTest < ActiveSupport::TestCase
  test "calls app once when tracing is disabled" do
    calls = 0
    app = lambda do |_env|
      calls += 1
      [ 200, {}, [ "ok" ] ]
    end

    response = Middleware::OtelLogTagsMiddleware.new(app).call({})

    assert_equal 1, calls
    assert_equal [ 200, {}, [ "ok" ] ], response
  end

  test "does not swallow name error raised by wrapped app" do
    app = ->(_env) { raise NameError, "boom" }

    assert_raises(NameError) do
      Middleware::OtelLogTagsMiddleware.new(app).call({})
    end
  end
end

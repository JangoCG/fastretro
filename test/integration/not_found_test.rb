require "test_helper"

class NotFoundTest < ActionDispatch::IntegrationTest
  setup do
    @show_detailed_exceptions = Rails.application.env_config["action_dispatch.show_detailed_exceptions"]
    Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false
  end

  teardown do
    Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = @show_detailed_exceptions
  end

  test "unknown public paths render a static 404 without requiring an account or modern browser" do
    untenanted do
      get "/iupjournals/index.php/esj",
        headers: { "User-Agent" => "Mozilla/5.0 (X11; Linux i686; rv:1.9.5.20) Gecko/ Firefox/3.6.12" }

      assert_response :not_found
      assert_nil response.location
      assert_select "title", /404/
      assert_select "script", count: 0
      assert_static_policy
    end
  end

  test "unknown paths return 404 for existing and missing accounts" do
    [ accounts(:one).external_account_id, 999999999999 ].each do |account_id|
      untenanted do
        get "/#{account_id}/missing-page"

        assert_response :not_found
        assert_nil response.location
      end
    end
  end

  test "unknown JSON paths return a JSON 404" do
    untenanted do
      get "/missing-page.json", headers: { "Accept" => "application/json" }

      assert_response :not_found
      assert_equal "application/json", response.media_type
      assert_equal({ "status" => 404, "error" => "Not Found" }, response.parsed_body)
    end
  end

  test "HEAD requests to unknown paths return 404 without a body" do
    untenanted do
      head "/missing-page"

      assert_response :not_found
      assert_nil response.location
      assert_empty response.body
    end
  end

  test "static error pages use an external stylesheet and a restrictive policy" do
    untenanted do
      %w[400 404 406-unsupported-browser 422 500].each do |page|
        get "/#{page}.html"

        assert_response :success
        assert_static_policy
        assert_select "style, script, [style]", count: 0
        assert_select "link[rel=stylesheet][href='/error.css']"
      end

      get "/error.css"
      assert_response :success
      assert_equal "text/css", response.media_type
    end
  end

  private
    def assert_static_policy
      policy = response.headers.fetch("Content-Security-Policy")
      assert_includes policy, "default-src 'none'"
      assert_includes policy, "style-src 'self'"
      assert_includes policy, "form-action 'none'"
      assert_includes policy, "frame-ancestors 'none'"
    end
end

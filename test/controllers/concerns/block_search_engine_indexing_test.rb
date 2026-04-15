require "test_helper"

class BlockSearchEngineIndexingTest < ActionDispatch::IntegrationTest
  test "sets X-Robots-Tag header to none on authenticated requests" do
    sign_in_as :one

    get retros_path
    assert_response :success
    assert_equal "none", response.headers["X-Robots-Tag"]
  end

  test "sets X-Robots-Tag header to none on unauthenticated requests" do
    untenanted do
      get new_session_path
    end

    assert_response :success
    assert_equal "none", response.headers["X-Robots-Tag"]
  end

  test "does not set X-Robots-Tag header on public SEO pages" do
    untenanted do
      get root_path
    end

    assert_response :success
    assert_nil response.headers["X-Robots-Tag"]
  end
end

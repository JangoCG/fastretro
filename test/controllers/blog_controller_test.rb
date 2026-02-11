require "test_helper"

class BlogControllerTest < ActionDispatch::IntegrationTest
  test "index includes nonce on structured data scripts" do
    untenanted do
      get blog_path
    end

    assert_response :success
    assert_no_match(/<script type="application\/ld\+json">/, response.body)
    assert_match(/<script type="application\/ld\+json" nonce="[^"]+">/, response.body)
  end

  test "show includes nonce on structured data scripts" do
    untenanted do
      get blog_post_path("aws-ses-rails-integration")
    end

    assert_response :success
    assert_no_match(/<script type="application\/ld\+json">/, response.body)
    assert_match(/<script type="application\/ld\+json" nonce="[^"]+">/, response.body)
  end
end

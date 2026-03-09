require "test_helper"
require "json"

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

  test "show renders valid structured data for descriptions with apostrophes" do
    untenanted do
      get blog_post_path("how-we-improved-rails-response-times-by-87-percent")
    end

    assert_response :success

    structured_data = JSON.parse(response.body[/<script type="application\/ld\+json" nonce="[^"]+">\s*(.*?)\s*<\/script>/m, 1])

    assert_equal "BlogPosting", structured_data.fetch("@type")
    assert_equal "We added Prometheus monitoring to Fast Retro and immediately spotted controllers with 200-400ms p95 latency. Here's how we traced them to N+1 queries and cut response times by up to 90%.", structured_data.fetch("description")
  end
end

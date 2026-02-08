require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "sitemap includes key public pages" do
    untenanted do
      get sitemap_path(format: :xml)

      assert_response :success
      assert_equal "application/xml; charset=utf-8", response.content_type

      assert_in_body root_url(script_name: nil)
      assert_in_body blog_url(script_name: nil)
      assert_in_body shoutouts_url(script_name: nil)
      assert_in_body imprint_url(script_name: nil)
      assert_in_body privacy_policy_url(script_name: nil)
      assert_in_body alternative_easyretro_url(script_name: nil)
      assert_in_body alternative_parabol_url(script_name: nil)
      assert_in_body alternative_metroretro_url(script_name: nil)
      assert_in_body alternative_teamretro_url(script_name: nil)
      assert_in_body new_session_url(script_name: nil)
      assert_in_body new_signup_url(script_name: nil)
    end
  end
end

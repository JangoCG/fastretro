require "test_helper"

class LegacyRedirectsTest < ActionDispatch::IntegrationTest
  test "legacy privacy urls redirect to canonical privacy policy page" do
    untenanted do
      get "/privacy-policy"
      assert_redirected_to "/privacy_policy"

      get "/privacy"
      assert_redirected_to "/privacy_policy"
    end
  end

  test "legacy retro create url redirects to retros new" do
    untenanted do
      get "/retro/create"
      assert_redirected_to "/retros/new"
    end
  end
end

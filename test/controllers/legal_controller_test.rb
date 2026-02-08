require "test_helper"

class LegalControllerTest < ActionDispatch::IntegrationTest
  test "privacy policy page is noindex" do
    untenanted do
      get privacy_policy_path

      assert_response :success
      assert_includes response.body, 'name="robots" content="noindex, follow"'
    end
  end

  test "imprint page is noindex" do
    untenanted do
      get imprint_path

      assert_response :success
      assert_includes response.body, 'name="robots" content="noindex, follow"'
    end
  end
end

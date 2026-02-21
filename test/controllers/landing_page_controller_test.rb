require "test_helper"

class LandingPageControllerTest < ActionDispatch::IntegrationTest
  test "root path shows landing page when unauthenticated" do
    untenanted do
      get root_path
      assert_response :success
      assert_select "h1", /RETROSPECTIVE/i
    end
  end

  test "root path redirects to session menu when authenticated without account scope" do
    sign_in_as :admin

    untenanted do
      get root_path
      assert_redirected_to session_menu_url(script_name: nil)
    end
  end

  test "root path with account scope redirects to retros list" do
    sign_in_as :admin

    get root_path
    assert_redirected_to retros_url
  end

  test "root_path with anchor parameter generates correct URL" do
    untenanted do
      # Anchor parameters generate URLs with fragments for client-side navigation
      url_with_anchor = root_path(anchor: "features", script_name: nil)
      assert_equal "/#features", url_with_anchor

      # Server request works normally (anchors are client-side)
      get root_path(script_name: nil)
      assert_response :success
    end
  end

  test "root_url returns absolute URL without account scope" do
    untenanted do
      expected_url = "http://www.example.com/"
      assert_equal expected_url, root_url(script_name: nil)
    end
  end

  test "root path with script_name nil works correctly" do
    untenanted do
      get root_path(script_name: nil)
      assert_response :success
    end
  end

  test "unauthenticated user can view landing page content" do
    untenanted do
      get root_path

      # Verify key landing page content is present
      assert_response :success
      assert_select "h1", text: /RETROSPECTIVE/i

      # Verify navigation links are present
      assert_select "a[href*='#features']", minimum: 1
      assert_select "a[href*='#pricing']", minimum: 1
    end
  end

  test "authenticated user without account sees session menu redirect even with anchor" do
    sign_in_as :admin

    untenanted do
      get root_path(anchor: "pricing")
      assert_redirected_to session_menu_url(script_name: nil)
    end
  end

end

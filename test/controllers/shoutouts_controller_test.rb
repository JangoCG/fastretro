require "test_helper"

class ShoutoutsControllerTest < ActionDispatch::IntegrationTest
  test "shoutouts page is visible when unauthenticated" do
    untenanted do
      get shoutouts_path

      assert_response :success
      assert_select "h1", text: /SHOUTOUTS/i
      assert_select "h2", text: /Jason Fried/i
      assert_select "a[href='https://x.com/jasonfried/status/2001073704608923705?s=20']", minimum: 1
      assert_select "img[alt='Jason Fried']", minimum: 1
      assert_select "img[src^='http']", count: 0
    end
  end

  test "shoutouts redirects authenticated user without account scope" do
    sign_in_as :admin

    untenanted do
      get shoutouts_path
      assert_redirected_to session_menu_url(script_name: nil)
    end
  end
end

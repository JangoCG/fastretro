require "test_helper"

class Admin::StatsControllerTest < ActionDispatch::IntegrationTest
  ACCESS_DENIED_ALERT = "You don't have access to this area."

  test "staff member can access admin stats" do
    sign_in_as :staff

    untenanted do
      get admin_stats_path
    end

    assert_response :success
  end

  test "non-staff member cannot access admin stats" do
    sign_in_as :one

    untenanted do
      get admin_stats_path
    end

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal ACCESS_DENIED_ALERT, flash[:alert]
  end

  test "unauthenticated user cannot access admin stats" do
    untenanted do
      get admin_stats_path
    end

    # Redirects to landing page for unauthenticated users
    assert_redirected_to landing_page_url(script_name: nil)
  end

  test "admin role user without staff flag cannot access admin stats" do
    sign_in_as :admin

    untenanted do
      get admin_stats_path
    end

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal ACCESS_DENIED_ALERT, flash[:alert]
  end
end

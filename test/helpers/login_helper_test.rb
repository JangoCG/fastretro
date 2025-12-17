require "test_helper"

class LoginHelperTest < ActionView::TestCase
  include LoginHelper

  test "login_url returns root_path without account scope" do
    assert_equal main_app.root_path(script_name: nil), login_url
  end

  test "logout_url returns root_path without account scope" do
    assert_equal main_app.root_path(script_name: nil), logout_url
  end

  test "login and logout urls point to the same landing page" do
    assert_equal login_url, logout_url
  end
end

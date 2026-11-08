require "test_helper"

class Sessions::TransfersControllerTest < ActionDispatch::IntegrationTest
  test "a transfer signs in exactly one browser session" do
    identity = identities(:one)
    token = identity.transfer_id
    path = session_transfer_path(token, script_name: nil)
    first_browser = open_session
    second_browser = open_session

    first_browser.patch path
    assert_equal 302, first_browser.response.status
    assert first_browser.cookies[:session_token].present?

    second_browser.patch path
    assert_equal 400, second_browser.response.status
    assert_not second_browser.cookies[:session_token].present?
  end

  test "visiting a transfer link does not consume it before confirmation" do
    token = identities(:one).transfer_id

    untenanted do
      get session_transfer_path(token)
      assert_response :success

      patch session_transfer_path(token)
      assert_response :redirect
      assert cookies[:session_token].present?
    end
  end
end

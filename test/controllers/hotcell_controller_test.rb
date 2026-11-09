require "test_helper"

class HotcellControllerTest < ActionDispatch::IntegrationTest
  test "health check reports availability without exposing diagnostics" do
    HotCell.expects(:diagnose).returns(stub(healthy?: true))

    untenanted { get "/hotcellz" }

    assert_response :success
    assert_equal "OK", response.body
  end

  test "health check reports an unavailable cell" do
    HotCell.expects(:diagnose).returns(stub(healthy?: false))

    untenanted { get "/hotcellz" }

    assert_response :service_unavailable
    assert_equal "FAIL", response.body
  end

  test "diagnostics require authentication" do
    HotCell.expects(:diagnose).never

    untenanted { get "/hotcellz/test" }

    assert_redirected_to root_url(script_name: nil)
  end

  test "diagnostics require staff" do
    sign_in_as :one
    HotCell.expects(:diagnose).never

    untenanted { get "/hotcellz/test" }

    assert_redirected_to session_menu_url(script_name: nil)
  end

  test "staff can inspect both sockets" do
    sign_in_as :staff
    HotCell.expects(:diagnose).with(work: true).returns(stub(healthy?: true, as_json: { healthy: true }))

    untenanted { get "/hotcellz/test" }

    assert_response :success
    assert_equal true, response.parsed_body["healthy"]
  end
end

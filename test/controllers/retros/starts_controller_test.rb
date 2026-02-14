require "test_helper"

class Retros::StartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    sign_in_as :one
  end

  test "turbo frame request returns redirect stream when skipping action review" do
    Account.any_instance.stubs(:has_completed_retros_with_actions?).returns(false)

    post retro_start_path(@retro), headers: {
      "Turbo-Frame" => "start-retro-container",
      "Accept" => "text/vnd.turbo-stream.html"
    }

    assert_response :success
    assert_includes response.media_type, "text/vnd.turbo-stream.html"
    assert_includes response.body, '<turbo-stream action="redirect"'
    assert_includes response.body, %(url="#{retro_brainstorming_path(@retro)}")
    assert_equal "brainstorming", @retro.reload.phase
  end
end

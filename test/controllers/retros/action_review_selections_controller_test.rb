require "test_helper"

class Retros::ActionReviewSelectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    sign_in_as :one
  end

  test "turbo frame request returns redirect stream when skipping review" do
    post retro_action_review_selection_path(@retro), params: { skip: "true" }, headers: {
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

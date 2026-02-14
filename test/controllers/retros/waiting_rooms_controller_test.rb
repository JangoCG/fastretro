require "test_helper"

class Retros::WaitingRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    sign_in_as :one
  end

  test "start retro form targets top-level frame for navigation" do
    get retro_waiting_room_path(@retro)

    assert_response :success
    assert_includes response.body, 'id="start-retro-container"'
    assert_includes response.body, 'data-turbo-frame="_top"'
  end

  test "subscribes waiting room to user-specific stream for phase redirects" do
    get retro_waiting_room_path(@retro)

    assert_response :success
    stream_name = Turbo::StreamsChannel.signed_stream_name([ @retro, users(:one) ])
    assert_includes response.body, stream_name
  end

  test "redirects to current phase when retro has already started" do
    @retro.update!(phase: :brainstorming)

    get retro_waiting_room_path(@retro)

    assert_redirected_to retro_brainstorming_path(@retro)
  end
end

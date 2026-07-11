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

  test "admin sees role controls for other participants" do
    participant = @retro.add_participant(users(:two))

    get retro_waiting_room_path(@retro)

    assert_response :success
    assert_includes response.body, "MAKE MODERATOR"
    assert_includes response.body, retro_participant_role_path(@retro, participant)
  end

  test "non-admin does not see role controls" do
    @retro.add_participant(users(:two))
    logout_and_sign_in_as :two

    get retro_waiting_room_path(@retro)

    assert_response :success
    assert_not_includes response.body, "MAKE MODERATOR"
  end
end

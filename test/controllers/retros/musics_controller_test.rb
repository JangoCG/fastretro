require "test_helper"

class Retros::MusicControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @admin_user = users(:one)
    @member_user = users(:two)
    # Add member as participant (non-admin)
    @retro.add_participant(@member_user, role: :participant)
  end

  test "admin can toggle music on" do
    sign_in_as :one
    @retro.update!(music_playing: false)

    patch retro_music_path(@retro)

    assert_response :ok
    assert @retro.reload.music_playing?
  end

  test "admin can toggle music off" do
    sign_in_as :one
    @retro.update!(music_playing: true)

    patch retro_music_path(@retro)

    assert_response :ok
    assert_not @retro.reload.music_playing?
  end

  test "non-admin participant cannot toggle music" do
    sign_in_as :two
    @retro.update!(music_playing: false)

    patch retro_music_path(@retro)

    assert_response :forbidden
    assert_not @retro.reload.music_playing?
  end

  test "unauthenticated user cannot toggle music" do
    @retro.update!(music_playing: false)

    patch retro_music_path(@retro, script_name: nil)

    assert_redirected_to session_menu_path(script_name: nil)
    assert_not @retro.reload.music_playing?
  end
end

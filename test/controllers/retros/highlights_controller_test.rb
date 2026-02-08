require "test_helper"

class Retros::HighlightsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @admin_user = users(:one)
    @member_user = users(:two)
    @retro.add_participant(@member_user, role: :participant)
  end

  test "admin can set highlight" do
    sign_in_as :one

    patch retro_highlight_path(@retro), params: { user_id: @member_user.id }

    assert_response :ok
    assert_equal @member_user.id, @retro.reload.highlighted_user_id
  end

  test "admin can toggle highlight off for same user" do
    sign_in_as :one
    @retro.update!(highlighted_user_id: @member_user.id)

    patch retro_highlight_path(@retro), params: { user_id: @member_user.id }

    assert_response :ok
    assert_nil @retro.reload.highlighted_user_id
  end

  test "admin can destroy highlight" do
    sign_in_as :one
    @retro.update!(highlighted_user_id: @member_user.id)

    delete retro_highlight_path(@retro)

    assert_response :ok
    assert_nil @retro.reload.highlighted_user_id
  end

  test "non-admin participant cannot set highlight" do
    sign_in_as :two

    patch retro_highlight_path(@retro), params: { user_id: @member_user.id }

    assert_redirected_to retros_path
    assert_nil @retro.reload.highlighted_user_id
  end

  test "unauthenticated user cannot set highlight" do
    patch retro_highlight_path(@retro, script_name: nil), params: { user_id: @member_user.id }

    assert_redirected_to session_menu_path(script_name: nil)
    assert_nil @retro.reload.highlighted_user_id
  end
end

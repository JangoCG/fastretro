require "test_helper"

class Retros::PhaseBacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @admin_user = users(:one)
    @member_user = users(:two)
    # Add member as participant (non-admin)
    @retro.add_participant(@member_user, role: :participant)
  end

  test "admin can go back from grouping to brainstorming" do
    sign_in_as :one
    @retro.update!(phase: :grouping)

    post retro_phase_back_path(@retro)

    assert_redirected_to retro_brainstorming_path(@retro)
    assert_equal "brainstorming", @retro.reload.phase
  end

  test "admin can go back from voting to grouping" do
    sign_in_as :one
    @retro.update!(phase: :voting)

    post retro_phase_back_path(@retro)

    assert_redirected_to retro_grouping_path(@retro)
    assert_equal "grouping", @retro.reload.phase
  end

  test "admin can go back from discussion to voting" do
    sign_in_as :one
    @retro.update!(phase: :discussion)

    post retro_phase_back_path(@retro)

    assert_redirected_to retro_voting_path(@retro)
    assert_equal "voting", @retro.reload.phase
  end

  test "admin can go back from complete to discussion" do
    sign_in_as :one
    @retro.update!(phase: :complete)

    post retro_phase_back_path(@retro)

    assert_redirected_to retro_discussion_path(@retro)
    assert_equal "discussion", @retro.reload.phase
  end

  test "non-admin participant cannot go back" do
    sign_in_as :two
    @retro.update!(phase: :grouping)

    post retro_phase_back_path(@retro)

    assert_redirected_to retros_path
    assert_equal "grouping", @retro.reload.phase
  end

  test "unauthenticated user cannot go back" do
    @retro.update!(phase: :grouping)

    post retro_phase_back_path(@retro, script_name: nil)

    assert_redirected_to session_menu_path(script_name: nil)
    assert_equal "grouping", @retro.reload.phase
  end

  test "going back does not change phase when already at brainstorming" do
    sign_in_as :one
    @retro.update!(phase: :brainstorming)

    post retro_phase_back_path(@retro)

    assert_redirected_to retro_brainstorming_path(@retro)
    assert_equal "brainstorming", @retro.reload.phase
  end
end

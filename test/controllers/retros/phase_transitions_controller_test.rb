require "test_helper"

class Retros::PhaseTransitionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @admin_user = users(:one)
    @member_user = users(:two)
    @retro.add_participant(@member_user, role: :participant)
  end

  test "admin can advance from brainstorming to grouping" do
    sign_in_as :one
    @retro.update!(phase: :brainstorming)

    post retro_phase_transition_path(@retro)

    assert_redirected_to retro_grouping_path(@retro)
    assert_equal "grouping", @retro.reload.phase
  end

  test "admin can advance from grouping to voting" do
    sign_in_as :one
    @retro.update!(phase: :grouping)

    post retro_phase_transition_path(@retro)

    assert_redirected_to retro_voting_path(@retro)
    assert_equal "voting", @retro.reload.phase
  end

  test "admin can advance from voting to discussion" do
    sign_in_as :one
    @retro.update!(phase: :voting)

    post retro_phase_transition_path(@retro)

    assert_redirected_to retro_discussion_path(@retro)
    assert_equal "discussion", @retro.reload.phase
  end

  test "admin can advance from discussion to complete" do
    sign_in_as :one
    @retro.update!(phase: :discussion)

    post retro_phase_transition_path(@retro)

    assert_redirected_to retro_complete_path(@retro)
    assert_equal "complete", @retro.reload.phase
  end

  test "non-admin participant cannot advance phase" do
    sign_in_as :two
    @retro.update!(phase: :brainstorming)

    post retro_phase_transition_path(@retro)

    assert_redirected_to retros_path
    assert_equal "brainstorming", @retro.reload.phase
  end

  test "unauthenticated user cannot advance phase" do
    @retro.update!(phase: :brainstorming)

    post retro_phase_transition_path(@retro, script_name: nil)

    assert_redirected_to session_menu_path(script_name: nil)
    assert_equal "brainstorming", @retro.reload.phase
  end
end

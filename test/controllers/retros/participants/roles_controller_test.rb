require "test_helper"

class Retros::Participants::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @admin_participant = retro_participants(:one_admin)
    @member_participant = @retro.add_participant(users(:two))
  end

  test "admin can promote a participant to moderator" do
    sign_in_as :one

    patch retro_participant_role_path(@retro, @member_participant), params: { participant: { role: "admin" } }

    assert_response :redirect
    assert @member_participant.reload.admin?
  end

  test "admin can demote another moderator" do
    @member_participant.update!(role: :admin)
    sign_in_as :one

    patch retro_participant_role_path(@retro, @member_participant), params: { participant: { role: "participant" } }

    assert_response :redirect
    assert @member_participant.reload.participant?
  end

  test "cannot demote the last moderator" do
    sign_in_as :one

    patch retro_participant_role_path(@retro, @admin_participant), params: { participant: { role: "participant" } }

    assert_response :redirect
    assert_equal "A retro needs at least one moderator.", flash[:alert]
    assert @admin_participant.reload.admin?
  end

  test "invalid role values are treated as participant" do
    @member_participant.update!(role: :admin)
    @retro.participants.create!(user: users(:admin), role: :admin)
    sign_in_as :one

    patch retro_participant_role_path(@retro, @member_participant), params: { participant: { role: "owner" } }

    assert @member_participant.reload.participant?
  end

  test "admin sees role controls in the participant sidebar during the retro" do
    @retro.update!(phase: :brainstorming)
    sign_in_as :one

    get retro_brainstorming_path(@retro)

    assert_response :success
    assert_in_body retro_participant_role_path(@retro, @member_participant)
  end

  test "non-admin does not see role controls in the participant sidebar" do
    @retro.update!(phase: :brainstorming)
    sign_in_as :two

    get retro_brainstorming_path(@retro)

    assert_response :success
    assert_not_includes response.body, retro_participant_role_path(@retro, @member_participant)
  end

  test "non-admin participant cannot change roles" do
    sign_in_as :two

    patch retro_participant_role_path(@retro, @member_participant), params: { participant: { role: "admin" } }

    assert_redirected_to retros_path
    assert @member_participant.reload.participant?
  end

  test "unauthenticated user cannot change roles" do
    patch retro_participant_role_path(@retro, @member_participant, script_name: nil), params: { participant: { role: "admin" } }

    assert_redirected_to session_menu_path(script_name: nil)
    assert @member_participant.reload.participant?
  end
end

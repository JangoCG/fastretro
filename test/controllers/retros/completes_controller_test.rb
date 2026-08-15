require "test_helper"

class Retros::CompletesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @retro.update!(phase: :complete)
  end

  test "retro admin sees jira export button even when integration is not configured" do
    sign_in_as :one

    get retro_complete_path(@retro)

    assert_response :success
    assert_includes response.body, "Export to Jira"
    assert_includes response.body, retro_jira_export_path(@retro)
  end

  test "the balloon game and its highscore are shown to every participant" do
    @retro.add_participant(users(:two), role: :participant)
    retro_participants(:one_admin).update!(balloons_popped: 12)
    sign_in_as :two

    get retro_complete_path(@retro)

    assert_response :success
    assert_includes response.body, "Balloon Pop"
    assert_includes response.body, retro_balloon_pops_path(@retro)
    assert_includes response.body, users(:one).name
  end

  test "non-admin participant does not see jira export button" do
    @retro.add_participant(users(:two), role: :participant)
    sign_in_as :two

    get retro_complete_path(@retro)

    assert_response :success
    assert_not_includes response.body, "Export to Jira"
  end
end

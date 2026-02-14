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

  test "non-admin participant does not see jira export button" do
    @retro.add_participant(users(:two), role: :participant)
    sign_in_as :two

    get retro_complete_path(@retro)

    assert_response :success
    assert_not_includes response.body, "Export to Jira"
  end
end

require "test_helper"

class Retros::JiraExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @retro.update!(phase: :complete)
    @admin_user = users(:one)
    @member_user = users(:two)
    @retro.add_participant(@member_user, role: :participant)

    @account = accounts(:one)
    @account.create_jira_integration!(
      site_url: "https://team.atlassian.net",
      email: "user@example.com",
      api_token: "secret-token",
      project_key: "RETRO"
    )
  end

  test "retro admin can trigger jira export" do
    sign_in_as :one

    assert_enqueued_with(job: Retro::JiraExportJob) do
      post retro_jira_export_path(@retro)
    end

    assert_redirected_to retro_complete_path(@retro)
  end

  test "non-admin participant cannot trigger jira export" do
    sign_in_as :two

    post retro_jira_export_path(@retro)

    assert_redirected_to retros_path
  end

  test "redirects to integration setup when not configured" do
    sign_in_as :one
    @account.jira_integration.destroy

    post retro_jira_export_path(@retro)

    assert_redirected_to account_jira_integration_path
  end
end

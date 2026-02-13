require "test_helper"

class Account::JiraIntegrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    sign_in_as :admin
  end

  test "show displays jira integration form" do
    get "#{account_path_prefix(@account)}/account/jira_integration"

    assert_response :success
  end

  test "create saves jira integration" do
    post "#{account_path_prefix(@account)}/account/jira_integration", params: {
      account_jira_integration: {
        site_url: "https://team.atlassian.net",
        email: "user@example.com",
        api_token: "secret-token",
        project_key: "RETRO",
        issue_type: "Task"
      }
    }

    assert_redirected_to account_jira_integration_path
    assert @account.reload.jira_integration.persisted?
  end

  test "update changes existing integration" do
    @account.create_jira_integration!(
      site_url: "https://old.atlassian.net",
      email: "old@example.com",
      api_token: "old-token",
      project_key: "OLD"
    )

    patch "#{account_path_prefix(@account)}/account/jira_integration", params: {
      account_jira_integration: {
        site_url: "https://new.atlassian.net",
        email: "new@example.com",
        api_token: "new-token",
        project_key: "NEW"
      }
    }

    assert_redirected_to account_jira_integration_path
    assert_equal "https://new.atlassian.net", @account.jira_integration.reload.site_url
  end

  test "update preserves api_token when submitted blank" do
    integration = @account.create_jira_integration!(
      site_url: "https://team.atlassian.net",
      email: "user@example.com",
      api_token: "original-token",
      project_key: "RETRO"
    )

    patch "#{account_path_prefix(@account)}/account/jira_integration", params: {
      account_jira_integration: {
        site_url: "https://team.atlassian.net",
        email: "user@example.com",
        api_token: "",
        project_key: "RETRO"
      }
    }

    assert_redirected_to account_jira_integration_path
    assert_equal "original-token", integration.reload.api_token
  end

  test "destroy removes integration" do
    @account.create_jira_integration!(
      site_url: "https://team.atlassian.net",
      email: "user@example.com",
      api_token: "secret-token",
      project_key: "RETRO"
    )

    delete "#{account_path_prefix(@account)}/account/jira_integration"

    assert_redirected_to account_settings_path
    assert_nil @account.reload.jira_integration
  end

  test "requires admin role" do
    logout_and_sign_in_as :two

    get "#{account_path_prefix(@account)}/account/jira_integration"

    assert_response :forbidden
  end

  test "cross-account access is denied" do
    other_account = accounts(:two)

    post "#{account_path_prefix(other_account)}/account/jira_integration", params: {
      account_jira_integration: {
        site_url: "https://hacked.atlassian.net",
        email: "hacker@example.com",
        api_token: "hacked-token",
        project_key: "HACK"
      }
    }

    assert_redirected_to session_menu_url(script_name: nil)
    assert_nil other_account.reload.jira_integration
  end
end

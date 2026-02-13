require "test_helper"

class Account::JiraIntegrationTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
  end

  test "valid with all required attributes" do
    integration = @account.build_jira_integration(
      site_url: "https://team.atlassian.net",
      email: "user@example.com",
      api_token: "secret-token",
      project_key: "RETRO"
    )

    assert integration.valid?
  end

  test "requires site_url, email, api_token, and project_key" do
    integration = @account.build_jira_integration

    assert_not integration.valid?
    assert integration.errors[:site_url].any?
    assert integration.errors[:email].any?
    assert integration.errors[:api_token].any?
    assert integration.errors[:project_key].any?
  end

  test "normalizes site_url by stripping and removing trailing slash" do
    integration = @account.build_jira_integration(site_url: "  https://team.atlassian.net/  ")

    assert_equal "https://team.atlassian.net", integration.site_url
  end

  test "normalizes email by stripping whitespace" do
    integration = @account.build_jira_integration(email: "  user@example.com  ")

    assert_equal "user@example.com", integration.email
  end

  test "normalizes project_key to uppercase and stripped" do
    integration = @account.build_jira_integration(project_key: "  retro  ")

    assert_equal "RETRO", integration.project_key
  end

  test "encrypts api_token" do
    integration = @account.create_jira_integration!(
      site_url: "https://team.atlassian.net",
      email: "user@example.com",
      api_token: "secret-token",
      project_key: "RETRO"
    )

    assert_not_equal "secret-token", Account::JiraIntegration.connection.select_value(
      "SELECT api_token FROM account_jira_integrations WHERE id = #{integration.id}"
    )
  end
end

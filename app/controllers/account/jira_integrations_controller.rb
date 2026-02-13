class Account::JiraIntegrationsController < ApplicationController
  before_action :ensure_admin
  before_action :set_jira_integration

  def show
  end

  def create
    @jira_integration = Current.account.build_jira_integration(jira_integration_params)

    if @jira_integration.save
      redirect_to account_jira_integration_path, notice: "Jira integration saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update
    if @jira_integration.update(jira_integration_params)
      redirect_to account_jira_integration_path, notice: "Jira integration updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @jira_integration.destroy
    redirect_to account_settings_path, notice: "Jira integration removed."
  end

  private
    def set_jira_integration
      @jira_integration = Current.account.jira_integration || Current.account.build_jira_integration
    end

    def jira_integration_params
      params.expect(account_jira_integration: %i[site_url email api_token project_key issue_type])
    end
end

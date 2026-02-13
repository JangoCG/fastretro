class Retros::JiraExportsController < ApplicationController
  before_action :set_retro

  def create
    jira = Current.account.jira_integration

    if jira&.configured?
      @retro.export_actions_to_jira_later
      redirect_to retro_complete_path(@retro), notice: "Exporting action items to Jira. They will appear in your project shortly."
    else
      redirect_to account_jira_integration_path
    end
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end
end

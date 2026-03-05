class Retros::JiraExportsController < ApplicationController
  include RetroAuthorization

  before_action :set_retro
  before_action :ensure_retro_admin

  def create
    jira = Current.account.jira_integration

    if jira&.persisted?
      @retro.export_actions_to_jira_later
      redirect_to retro_complete_path(@retro), notice: t("flash.jira_export_started")
    else
      redirect_to account_jira_integration_path
    end
  end

  private
    def set_retro
      @retro = Current.account.retros.find(params[:retro_id])
    end
end

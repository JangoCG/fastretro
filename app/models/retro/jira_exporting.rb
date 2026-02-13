module Retro::JiraExporting
  extend ActiveSupport::Concern

  def export_actions_to_jira_later
    Retro::JiraExportJob.perform_later(self)
  end

  def export_actions_to_jira_now
    jira = account.jira_integration

    actions.published.where(exported_to_jira_at: nil).includes(:user).find_each do |action|
      jira.create_issue(
        summary: action.content.to_plain_text.truncate(255),
        description: "Retro: #{name}\nAuthor: #{action.user.name}\nDate: #{created_at.to_date}"
      )
      action.update_column(:exported_to_jira_at, Time.current)
    end
  end
end

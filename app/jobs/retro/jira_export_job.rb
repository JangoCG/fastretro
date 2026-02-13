class Retro::JiraExportJob < ApplicationJob
  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 3

  def perform(retro)
    retro.export_actions_to_jira_now
  end
end

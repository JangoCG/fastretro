class CreateAccountJiraIntegrations < ActiveRecord::Migration[8.1]
  def change
    create_table :account_jira_integrations do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.string :site_url, null: false
      t.string :email, null: false
      t.string :api_token, null: false
      t.string :project_key, null: false
      t.string :issue_type, default: "Task"
      t.timestamps
    end
  end
end

class AddExportedToJiraAtToActions < ActiveRecord::Migration[8.1]
  def change
    add_column :actions, :exported_to_jira_at, :datetime
  end
end

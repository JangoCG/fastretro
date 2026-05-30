class AddRetentionReminderSentAtToRetros < ActiveRecord::Migration[8.1]
  def change
    add_column :retros, :retention_reminder_sent_at, :datetime
  end
end

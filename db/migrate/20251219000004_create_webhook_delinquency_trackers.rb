class CreateWebhookDelinquencyTrackers < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_delinquency_trackers do |t|
      t.references :account, null: false, foreign_key: true
      t.references :webhook, null: false, foreign_key: true, index: { unique: true }
      t.integer :consecutive_failures_count, null: false, default: 0
      t.datetime :first_failure_at

      t.timestamps
    end
  end
end

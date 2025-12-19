class CreateWebhookDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_deliveries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :webhook, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :state, null: false, default: "pending"
      t.text :request
      t.text :response

      t.timestamps
    end
  end
end

class CreateWebhooks < ActiveRecord::Migration[8.1]
  def change
    create_table :webhooks do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.text :url, null: false
      t.string :signing_secret, null: false
      t.text :subscribed_actions
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end

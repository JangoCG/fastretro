class CreateAccountSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :account_subscriptions do |t|
      t.references :account, null: false, foreign_key: true, index: true
      t.string :plan_key
      t.string :stripe_customer_id, index: { unique: true }
      t.string :stripe_subscription_id, index: { unique: true }
      t.string :status
      t.datetime :current_period_end
      t.datetime :cancel_at

      t.timestamps
    end
  end
end

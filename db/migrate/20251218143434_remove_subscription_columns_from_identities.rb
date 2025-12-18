class RemoveSubscriptionColumnsFromIdentities < ActiveRecord::Migration[8.1]
  def change
    remove_column :identities, :stripe_customer_id, :string if column_exists?(:identities, :stripe_customer_id)
    remove_column :identities, :plan, :string if column_exists?(:identities, :plan)
    remove_column :identities, :subscription_status, :string if column_exists?(:identities, :subscription_status)
    remove_column :identities, :subscription_ends_at, :datetime if column_exists?(:identities, :subscription_ends_at)

    remove_index :identities, :stripe_customer_id if index_exists?(:identities, :stripe_customer_id)
  end
end

class AddColumnsToIdentities < ActiveRecord::Migration[8.1]
  def change
    add_column :identities, :stripe_customer_id, :string
    add_column :identities, :plan, :string
    add_column :identities, :subscription_status, :string
    add_column :identities, :subscription_ends_at, :datetime
  end
end

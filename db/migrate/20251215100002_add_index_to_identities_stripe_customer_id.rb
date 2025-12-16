class AddIndexToIdentitiesStripeCustomerId < ActiveRecord::Migration[8.1]
  def change
    add_index :identities, :stripe_customer_id, unique: true
  end
end

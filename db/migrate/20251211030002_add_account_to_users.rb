class AddAccountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :account, foreign_key: true
    add_column :users, :role, :string, default: "member", null: false
    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :verified_at, :datetime

    # Ensure one identity can only have one user per account
    add_index :users, [ :account_id, :identity_id ], unique: true
  end
end

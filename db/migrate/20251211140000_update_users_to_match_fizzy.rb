class UpdateUsersToMatchFizzy < ActiveRecord::Migration[8.1]
  def change
    # Remove email_address from users (it's on identity)
    remove_column :users, :email_address, :string

    # Make name required
    change_column_null :users, :name, false

    # Add index on account_id and role
    add_index :users, [ :account_id, :role ]

    # Add expires_at index on magic_links
    add_index :magic_links, :expires_at
  end
end

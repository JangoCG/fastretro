class UpdateUsersForIdentity < ActiveRecord::Migration[8.1]
  def change
    # Remove password-related columns
    remove_column :users, :password_digest, :string

    # Add identity reference
    add_reference :users, :identity, foreign_key: true

    # Add name column for user display name
    add_column :users, :name, :string
  end
end

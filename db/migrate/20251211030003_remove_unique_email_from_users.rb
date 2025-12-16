class RemoveUniqueEmailFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, :email_address
  end
end

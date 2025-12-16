class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.bigint :external_account_id, null: false

      t.timestamps
    end
    add_index :accounts, :external_account_id, unique: true
  end
end

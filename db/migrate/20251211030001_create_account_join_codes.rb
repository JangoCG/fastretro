class CreateAccountJoinCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :account_join_codes do |t|
      t.references :account, null: false, foreign_key: true
      t.string :code, null: false
      t.integer :usage_count, default: 0, null: false
      t.integer :usage_limit, default: 10, null: false

      t.timestamps
    end
    add_index :account_join_codes, :code, unique: true
  end
end

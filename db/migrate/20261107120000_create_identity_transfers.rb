class CreateIdentityTransfers < ActiveRecord::Migration[8.1]
  def change
    create_table :identity_transfers do |t|
      t.integer :identity_id, null: false
      t.string :token, null: false

      t.timestamps

      t.index :identity_id
      t.index :token, unique: true
    end
  end
end

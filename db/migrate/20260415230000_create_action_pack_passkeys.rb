class CreateActionPackPasskeys < ActiveRecord::Migration[8.1]
  def change
    create_table :action_pack_passkeys do |t|
      t.string :credential_id, null: false
      t.binary :public_key, null: false
      t.integer :sign_count, default: 0, null: false
      t.string :aaguid
      t.boolean :backed_up
      t.text :transports
      t.string :name
      t.references :holder, polymorphic: true, null: false

      t.timestamps
    end

    add_index :action_pack_passkeys, :credential_id, unique: true
  end
end

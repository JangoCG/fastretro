class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :account, null: false, foreign_key: true
      t.references :retro, null: false, foreign_key: true
      t.references :creator, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :eventable_type, null: false
      t.integer :eventable_id, null: false
      t.json :particulars, default: {}

      t.timestamps
    end

    add_index :events, [ :account_id, :action ]
    add_index :events, [ :eventable_type, :eventable_id ]
  end
end

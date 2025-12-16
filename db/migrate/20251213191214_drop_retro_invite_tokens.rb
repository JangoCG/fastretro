class DropRetroInviteTokens < ActiveRecord::Migration[8.1]
  def change
    drop_table :retro_invite_tokens do |t|
      t.integer :retro_id, null: false
      t.string :token, null: false
      t.timestamps

      t.index :retro_id
      t.index :token, unique: true
    end
  end
end

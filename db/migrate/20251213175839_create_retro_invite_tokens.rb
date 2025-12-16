class CreateRetroInviteTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :retro_invite_tokens do |t|
      t.references :retro, null: false, foreign_key: true
      t.string :token, null: false

      t.timestamps
    end
    add_index :retro_invite_tokens, :token, unique: true
  end
end

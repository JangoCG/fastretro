class CreateRetroParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :retro_participants do |t|
      t.references :retro, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "participant"

      t.timestamps
    end

    add_index :retro_participants, [ :retro_id, :user_id ], unique: true
  end
end

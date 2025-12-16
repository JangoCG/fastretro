class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :retro_participant, null: false, foreign_key: true
      t.references :voteable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :votes, [ :voteable_type, :voteable_id ]
  end
end

class CreateActions < ActiveRecord::Migration[8.1]
  def change
    create_table :actions do |t|
      t.references :retro, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "drafted"

      t.timestamps
    end
  end
end

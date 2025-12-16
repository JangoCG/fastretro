class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :retro, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :category, null: false
      t.string :status, default: "drafted", null: false

      t.timestamps
    end
  end
end

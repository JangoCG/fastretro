class CreateFeedbackGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :feedback_groups do |t|
      t.references :retro, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end

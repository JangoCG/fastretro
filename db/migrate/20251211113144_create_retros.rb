class CreateRetros < ActiveRecord::Migration[8.1]
  def change
    create_table :retros do |t|
      t.string :name

      t.timestamps
    end
  end
end

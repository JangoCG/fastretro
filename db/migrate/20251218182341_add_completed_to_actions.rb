class AddCompletedToActions < ActiveRecord::Migration[8.1]
  def change
    add_column :actions, :completed, :boolean, default: false, null: false
  end
end

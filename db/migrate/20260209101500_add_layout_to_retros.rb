class AddLayoutToRetros < ActiveRecord::Migration[8.1]
  def change
    add_column :retros, :layout_mode, :string, default: "default", null: false
    add_column :retros, :column_layout, :json, default: [], null: false
  end
end

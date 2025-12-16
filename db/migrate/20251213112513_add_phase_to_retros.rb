class AddPhaseToRetros < ActiveRecord::Migration[8.1]
  def change
    add_column :retros, :phase, :string, default: "waiting_room", null: false
  end
end

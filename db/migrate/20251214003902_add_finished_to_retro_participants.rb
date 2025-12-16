class AddFinishedToRetroParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :retro_participants, :finished, :boolean, default: false, null: false
  end
end

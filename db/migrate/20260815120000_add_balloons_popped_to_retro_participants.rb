class AddBalloonsPoppedToRetroParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :retro_participants, :balloons_popped, :integer, default: 0, null: false
  end
end

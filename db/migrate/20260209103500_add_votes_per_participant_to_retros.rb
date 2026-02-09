class AddVotesPerParticipantToRetros < ActiveRecord::Migration[8.1]
  def change
    add_column :retros, :votes_per_participant, :integer, default: 3, null: false
  end
end

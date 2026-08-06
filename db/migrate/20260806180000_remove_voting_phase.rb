class RemoveVotingPhase < ActiveRecord::Migration[8.1]
  def up
    # Retros mid-vote move on to discussion; the phase no longer exists for them to sit in.
    execute "UPDATE retros SET phase = 'discussion' WHERE phase = 'voting'"

    drop_table :votes
    remove_column :retros, :votes_per_participant
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Votes cannot be restored once dropped"
  end
end

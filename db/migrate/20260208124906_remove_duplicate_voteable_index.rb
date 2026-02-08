class RemoveDuplicateVoteableIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :votes, name: "index_votes_on_voteable_type_and_voteable_id"
  end
end

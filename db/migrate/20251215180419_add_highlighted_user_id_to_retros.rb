class AddHighlightedUserIdToRetros < ActiveRecord::Migration[8.1]
  def change
    add_column :retros, :highlighted_user_id, :integer
  end
end

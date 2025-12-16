class UpdateSessionsForIdentity < ActiveRecord::Migration[8.1]
  def change
    # Remove user reference
    remove_reference :sessions, :user, foreign_key: true

    # Add identity reference
    add_reference :sessions, :identity, null: false, foreign_key: true
  end
end

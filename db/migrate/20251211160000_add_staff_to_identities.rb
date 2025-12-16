class AddStaffToIdentities < ActiveRecord::Migration[8.0]
  def change
    add_column :identities, :staff, :boolean, null: false, default: false
  end
end

class AddAccountToRetros < ActiveRecord::Migration[8.1]
  def change
    add_reference :retros, :account, null: false, foreign_key: true
  end
end

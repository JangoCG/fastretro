class SwitchFreeLimitFromFeedbacksToRetros < ActiveRecord::Migration[8.1]
  def up
    add_column :accounts, :retros_count, :integer, default: 0, null: false

    execute <<~SQL
      UPDATE accounts SET retros_count = (
        SELECT COUNT(*) FROM retros WHERE retros.account_id = accounts.id
      )
    SQL

    remove_column :accounts, :feedbacks_count
    remove_column :identities, :lifetime_feedbacks_count
  end

  def down
    add_column :accounts, :feedbacks_count, :integer, default: 0, null: false
    add_column :identities, :lifetime_feedbacks_count, :integer, default: 0, null: false
    remove_column :accounts, :retros_count
  end
end

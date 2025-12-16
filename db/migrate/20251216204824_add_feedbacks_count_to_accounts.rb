class AddFeedbacksCountToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :feedbacks_count, :integer, default: 0, null: false
  end
end

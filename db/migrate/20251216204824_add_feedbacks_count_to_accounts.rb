class AddFeedbacksCountToAccounts < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:accounts, :feedbacks_count)
      add_column :accounts, :feedbacks_count, :integer, default: 0, null: false
    end
  end
end

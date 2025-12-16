class AddLifetimeFeedbacksCountToIdentities < ActiveRecord::Migration[8.1]
  def change
    add_column :identities, :lifetime_feedbacks_count, :integer, default: 0, null: false
  end
end

class AddDiscussedToFeedbackItems < ActiveRecord::Migration[8.1]
  def change
    add_column :feedbacks, :discussed, :boolean, default: false, null: false
    add_column :feedback_groups, :discussed, :boolean, default: false, null: false
  end
end

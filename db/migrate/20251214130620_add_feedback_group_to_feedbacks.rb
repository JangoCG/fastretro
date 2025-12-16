class AddFeedbackGroupToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_reference :feedbacks, :feedback_group, null: true, foreign_key: true
  end
end

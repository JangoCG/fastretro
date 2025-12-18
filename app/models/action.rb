class Action < ApplicationRecord
  include Action::Statuses

  belongs_to :retro
  belongs_to :user, default: -> { Current.user }

  broadcasts_refreshes_to :retro

  has_rich_text :content

  scope :incomplete, -> { where(completed: false) }
  scope :completed_actions, -> { where(completed: true) }

  def toggle_completion!
    update!(completed: !completed)
  end
end

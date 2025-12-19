class Action < ApplicationRecord
  include Action::Statuses
  include Eventable

  belongs_to :retro
  belongs_to :user, default: -> { Current.user }

  broadcasts_refreshes_to :retro

  has_rich_text :content

  scope :incomplete, -> { where(completed: false) }
  scope :completed_actions, -> { where(completed: true) }

  before_destroy :record_deleted_event

  def toggle_completion!
    update!(completed: !completed)
    record_event("action.completed") if completed?
  end

  private
    def record_deleted_event
      Event.create!(
        account: retro.account,
        retro: retro,
        action: "action.deleted",
        creator: Current.user,
        eventable: self
      )
    end
end

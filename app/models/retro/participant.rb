class Retro::Participant < ApplicationRecord
  self.table_name = "retro_participants"

  belongs_to :retro
  belongs_to :user
  has_many :votes, class_name: "Vote", foreign_key: :retro_participant_id, inverse_of: :retro_participant, dependent: :destroy

  broadcasts_refreshes_to :retro

  enum :role, { admin: "admin", participant: "participant" }

  validates :user_id, uniqueness: { scope: :retro_id }

  delegate :name, :initials, to: :user

  def finish!
    update!(finished: true)
  end

  def unfinish!
    update!(finished: false)
  end

  def toggle_finished!
    update!(finished: !finished)
  end
end

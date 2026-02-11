class Retro::Participant < ApplicationRecord
  self.table_name = "retro_participants"

  belongs_to :retro
  belongs_to :user
  has_many :votes, class_name: "Vote", foreign_key: :retro_participant_id, inverse_of: :retro_participant, dependent: :destroy

  after_commit :broadcast_targeted_participant_updates

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

  private

  def broadcast_targeted_participant_updates
    return unless retro.present?

    participants = retro.participants.includes(:user).order(:created_at).to_a

    if retro.waiting_room?
      Turbo::StreamsChannel.broadcast_replace_to(
        retro,
        target: "waiting-room-participants",
        partial: "retros/waiting_rooms/participants_section",
        locals: { retro:, participants: }
      )
    else
      participants.each do |participant|
        next unless participant.user.present?

        Current.set(account: retro.account, user: participant.user) do
          Turbo::StreamsChannel.broadcast_replace_to(
            [ retro, participant.user ],
            target: "participant-list",
            partial: "retros/streams/participant_list",
            locals: { retro:, participants: }
          )
        end
      end
    end
  end
end

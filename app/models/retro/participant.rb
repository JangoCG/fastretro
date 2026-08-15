class Retro::Participant < ApplicationRecord
  MAX_BALLOON_POPS_PER_REQUEST = 50

  self.table_name = "retro_participants"

  belongs_to :retro
  belongs_to :user
  has_many :votes, class_name: "Vote", foreign_key: :retro_participant_id, inverse_of: :retro_participant, dependent: :destroy

  after_commit :broadcast_targeted_participant_updates
  after_update_commit :broadcast_role_change_refresh, if: :saved_change_to_role?

  enum :role, { admin: "admin", participant: "participant" }

  validates :user_id, uniqueness: { scope: :retro_id }
  validate :ensure_retro_keeps_an_admin, on: :update

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

  # Counts balloons popped in the celebration game of the complete phase. Pops arrive
  # in batches from the browser, so a batch is clamped to what a human hand could
  # manage in one flush - the controller's rate limit is what bounds a rigged client
  # over time. Anything that isn't a number counts as no pops at all, since the
  # count comes straight off a request.
  #
  # Incrementing skips callbacks, which keeps a pop from dragging the whole
  # participant list through a broadcast - only the highscore goes out.
  def pop_balloons(count)
    pops = count.to_s.to_i.clamp(0, MAX_BALLOON_POPS_PER_REQUEST)

    if pops.positive?
      increment!(:balloons_popped, pops)
      broadcast_balloon_leaderboard
    end
  end

  private

  def broadcast_balloon_leaderboard
    leaderboard = BalloonLeaderboardComponent.new(retro:)

    Turbo::StreamsChannel.broadcast_replace_to(
      retro,
      target: leaderboard.dom_id,
      attributes: { method: :morph },
      html: ApplicationController.render(leaderboard, layout: false)
    )
  end

  def ensure_retro_keeps_an_admin
    if role_changed?(from: "admin", to: "participant") && retro.participants.admin.where.not(id: id).none?
      errors.add(:base, :last_admin)
    end
  end

  def broadcast_targeted_participant_updates
    return unless retro.present?

    participants = retro.participants.includes(:user).order(:created_at).to_a

    # Each payload only differs by whether the viewer is an admin, so render
    # each variant once and fan the cached HTML out to every stream.
    section_html_by_admin = {}
    list_html_by_admin = {}
    confirm_phase_html = nil

    participants.each do |participant|
      next unless participant.user.present?

      Current.set(account: retro.account, user: participant.user) do
        if retro.waiting_room?
          html = section_html_by_admin[participant.admin?] ||= ApplicationController.render(
            partial: "retros/waiting_rooms/participants_section",
            locals: { retro:, participants: }
          )

          Turbo::StreamsChannel.broadcast_replace_to(
            [ retro, participant.user ],
            target: "waiting-room-participants",
            html: html
          )
        else
          html = list_html_by_admin[participant.admin?] ||= ApplicationController.render(
            partial: "retros/streams/participant_list",
            locals: { retro:, participants: }
          )

          Turbo::StreamsChannel.broadcast_replace_to(
            [ retro, participant.user ],
            target: "participant-list",
            attributes: { method: :morph },
            html: html
          )

          if participant.admin?
            confirm_phase_html ||= ApplicationController.render(
              partial: "retros/streams/confirm_phase_status",
              locals: { retro: }
            )

            Turbo::StreamsChannel.broadcast_replace_to(
              [ retro, participant.user ],
              target: "confirm-phase-status",
              html: confirm_phase_html
            )
          end
        end
      end
    end
  end

  def broadcast_role_change_refresh
    Turbo::StreamsChannel.broadcast_refresh_to([ retro, user ]) if user.present?
  end
end

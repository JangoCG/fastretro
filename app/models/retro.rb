class Retro < ApplicationRecord
  belongs_to :account

  has_many :feedbacks, dependent: :destroy
  has_many :feedback_groups, dependent: :destroy
  has_many :actions, dependent: :destroy
  has_many :participants, class_name: "Retro::Participant", dependent: :destroy
  has_many :users, through: :participants

  enum :phase, { waiting_room: "waiting_room", brainstorming: "brainstorming", grouping: "grouping", voting: "voting", discussion: "discussion", complete: "complete" }

  PHASE_ORDER = %i[waiting_room brainstorming grouping voting discussion complete].freeze

  def start!
    update!(phase: :brainstorming)
  end

  def finish_brainstorming!
    update!(phase: :grouping)
  end

  def advance_phase!
    current_index = PHASE_ORDER.index(phase.to_sym)
    return if current_index.nil? || current_index >= PHASE_ORDER.length - 1

    next_phase = PHASE_ORDER[current_index + 1]
    update!(phase: next_phase, highlighted_user_id: nil)
    participants.update_all(finished: false)
  end

  def next_phase
    current_index = PHASE_ORDER.index(phase.to_sym)
    return nil if current_index.nil? || current_index >= PHASE_ORDER.length - 1
    PHASE_ORDER[current_index + 1]
  end

  def last_phase?
    phase.to_sym == PHASE_ORDER.last
  end

  def add_participant(user, role: :participant)
    participants.find_or_create_by!(user: user) do |p|
      p.role = role
    end
  end

  def participant?(user)
    participants.exists?(user: user)
  end

  def admin?(user)
    participants.admin.exists?(user: user)
  end

  def owner
    participants.admin.order(:created_at).first&.user
  end
end

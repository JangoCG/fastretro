class Retro < ApplicationRecord
  LANDING_PAGE_RETRO_COUNT_CACHE_KEY = "landing_page:retro_count".freeze

  belongs_to :account

  has_many :feedbacks, dependent: :destroy
  has_many :feedback_groups, dependent: :destroy
  has_many :actions, dependent: :destroy
  has_many :participants, class_name: "Retro::Participant", dependent: :destroy
  has_many :users, through: :participants

  enum :phase, { waiting_room: "waiting_room", action_review: "action_review", brainstorming: "brainstorming", grouping: "grouping", voting: "voting", discussion: "discussion", complete: "complete" }

  PHASE_ORDER = %i[waiting_room action_review brainstorming grouping voting discussion complete].freeze

  after_commit :expire_landing_page_retro_count_cache, on: %i[create destroy]

  def self.cached_global_count
    Rails.cache.fetch(
      LANDING_PAGE_RETRO_COUNT_CACHE_KEY,
      expires_in: 12.hours,
      race_condition_ttl: 10.minutes
    ) { count }
  end

  def start!(skip_action_review: false)
    if skip_action_review || !account.has_completed_retros_with_actions?
      update!(phase: :brainstorming)
    else
      update!(phase: :action_review)
    end
  end

  def finish_brainstorming!
    update!(phase: :grouping)
  end

  def advance_phase!
    current_index = PHASE_ORDER.index(phase.to_sym)
    return if current_index.nil? || current_index >= PHASE_ORDER.length - 1

    # Clean up completed actions when leaving action_review phase
    cleanup_completed_actions if action_review?

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

  def back_phase!
    current_index = PHASE_ORDER.index(phase.to_sym)
    return if current_index.nil? || current_index <= PHASE_ORDER.index(:brainstorming)

    cleanup_votes if voting?

    prev_phase = PHASE_ORDER[current_index - 1]
    update!(phase: prev_phase, highlighted_user_id: nil)
    participants.update_all(finished: false)
  end

  def previous_phase
    current_index = PHASE_ORDER.index(phase.to_sym)
    return nil if current_index.nil? || current_index <= PHASE_ORDER.index(:brainstorming)
    PHASE_ORDER[current_index - 1]
  end

  def can_go_back?
    current_index = PHASE_ORDER.index(phase.to_sym)
    current_index.present? && current_index > PHASE_ORDER.index(:brainstorming)
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

  # Find completed retros with published actions
  def self.completed_with_actions
    where(phase: :complete)
      .joins(:actions)
      .where(actions: { status: :published })
      .distinct
      .order(created_at: :desc)
  end

  # Copy published actions from another retro
  def import_actions_from(source_retro)
    source_retro.actions.published.find_each do |action|
      actions.create!(
        user: action.user,
        status: :published,
        content: action.content.body.to_s,
        completed: false
      )
    end
  end

  # Remove completed actions (called when leaving action_review phase)
  def cleanup_completed_actions
    actions.completed_actions.destroy_all
  end

  # Remove all votes (called when going back from voting phase)
  def cleanup_votes
    Vote.where(retro_participant: participants).delete_all
  end

  private
    def expire_landing_page_retro_count_cache
      Rails.cache.delete(LANDING_PAGE_RETRO_COUNT_CACHE_KEY)
    end
end

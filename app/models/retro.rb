class Retro < ApplicationRecord
  include Retro::JiraExporting

  LANDING_PAGE_RETRO_COUNT_CACHE_KEY = "landing_page:retro_count".freeze
  DEFAULT_VOTES_PER_PARTICIPANT = 3
  LAYOUT_MODES = %w[default custom].freeze
  DEFAULT_COLUMN_LAYOUT = [
    { "id" => "went_well", "name" => "Good" },
    { "id" => "could_be_better", "name" => "Bad" },
    { "id" => "wants", "name" => "Want" }
  ].freeze

  belongs_to :account

  has_many :feedbacks, dependent: :destroy
  has_many :feedback_groups, dependent: :destroy
  has_many :actions, dependent: :destroy
  has_many :participants, class_name: "Retro::Participant", dependent: :destroy
  has_many :users, through: :participants

  enum :phase, { waiting_room: "waiting_room", action_review: "action_review", brainstorming: "brainstorming", grouping: "grouping", voting: "voting", discussion: "discussion", complete: "complete" }

  PHASE_ORDER = %i[waiting_room action_review brainstorming grouping voting discussion complete].freeze

  before_validation :normalize_layout_fields

  validates :layout_mode, inclusion: { in: LAYOUT_MODES }
  validates :votes_per_participant,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 20 }
  validate :column_layout_presence

  after_commit :expire_landing_page_retro_count_cache, on: %i[create destroy]

  def self.default_column_layout
    DEFAULT_COLUMN_LAYOUT.map(&:dup)
  end

  def self.build_column_layout_from_names(column_names)
    normalize_column_layout(Array(column_names).map { |name| { "name" => name } })
  end

  def self.normalize_column_layout(raw_layout)
    used_ids = []

    Array(raw_layout).filter_map.with_index(1) do |column, index|
      name = column_name_from(column).to_s.strip
      next if name.blank?

      requested_id = column_id_from(column)
      id = normalized_column_id(requested_id.presence || name, index, used_ids)
      used_ids << id
      { "id" => id, "name" => name }
    end
  end

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

  def configure_column_layout(layout_mode:, column_names:, votes_per_participant: nil)
    self.layout_mode = layout_mode.to_s == "custom" ? "custom" : "default"
    self.column_layout = if self.layout_mode == "custom"
      self.class.build_column_layout_from_names(column_names)
    else
      self.class.default_column_layout
    end
    self.votes_per_participant = if self.layout_mode == "custom"
      votes_per_participant.presence || DEFAULT_VOTES_PER_PARTICIPANT
    else
      DEFAULT_VOTES_PER_PARTICIPANT
    end
  end

  def custom_layout?
    layout_mode == "custom"
  end

  def default_layout?
    !custom_layout?
  end

  def column_definitions
    normalized_columns = self.class.normalize_column_layout(column_layout)
    return normalized_columns if custom_layout?

    normalized_columns.presence || self.class.default_column_layout
  end

  def column_categories
    column_definitions.map { |column| column["id"] }
  end

  def column_name_for(category)
    category_id = category.to_s
    column_definitions.find { |column| column["id"] == category_id }&.fetch("name", nil) || category_id.humanize
  end

  def category_exists?(category)
    column_categories.include?(category.to_s)
  end

  def max_votes_per_participant
    votes_per_participant
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
    return false if user.blank?

    if participants.loaded?
      participants.any? { |participant| participant.user_id == user.id && participant.admin? }
    else
      @admin_by_user_id ||= {}
      @admin_by_user_id.fetch(user.id) do
        @admin_by_user_id[user.id] = participants.admin.exists?(user:)
      end
    end
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
    def normalize_layout_fields
      self.layout_mode = layout_mode.presence
      self.layout_mode = "default" unless LAYOUT_MODES.include?(layout_mode)

      normalized_columns = self.class.normalize_column_layout(column_layout)
      self.column_layout = if custom_layout?
        normalized_columns
      else
        normalized_columns.presence || self.class.default_column_layout
      end

      if custom_layout?
        self.votes_per_participant = votes_per_participant.presence || DEFAULT_VOTES_PER_PARTICIPANT
      else
        self.votes_per_participant = DEFAULT_VOTES_PER_PARTICIPANT
      end
    end

    def column_layout_presence
      return if column_layout.present?

      errors.add(:column_layout, "must include at least one column")
    end

    def expire_landing_page_retro_count_cache
      Rails.cache.delete(LANDING_PAGE_RETRO_COUNT_CACHE_KEY)
    end

    def self.column_name_from(column)
      return column["name"] || column[:name] if column.respond_to?(:[])

      column
    end

    def self.column_id_from(column)
      return column["id"] || column[:id] if column.respond_to?(:[])

      nil
    end

    def self.normalized_column_id(value, index, used_ids)
      base_id = value.to_s.parameterize(separator: "_")
      base_id = "column_#{index}" if base_id.blank?

      candidate = base_id
      suffix = 2
      while used_ids.include?(candidate)
        candidate = "#{base_id}_#{suffix}"
        suffix += 1
      end

      candidate
    end
end

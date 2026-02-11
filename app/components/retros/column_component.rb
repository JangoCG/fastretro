class Retros::ColumnComponent < ApplicationComponent
  HIGHLIGHT_COLORS = %w[#22c55e #fb923c #38bdf8 #a78bfa #eab308 #f43f5e].freeze

  def initialize(retro:, category:, title: nil, position: 0, participant: nil, feedbacks: nil, has_feedbacks: nil)
    @retro = retro
    @category = category
    @title = title
    @position = position.to_i
    @participant = participant
    @preloaded_feedbacks = feedbacks
    @has_feedbacks = has_feedbacks
  end

  private

  def feedbacks
    @feedbacks ||= begin
      base = if @preloaded_feedbacks
        @preloaded_feedbacks
      else
        relation = @retro.feedbacks.published.in_category(@category).includes(:user, :rich_text_content, :feedback_group)
        relation = relation.includes(:votes, feedback_group: :votes) if show_vote_results?
        if @retro.brainstorming?
          relation.where(user: Current.user)
        else
          relation
        end
      end

      if @preloaded_feedbacks && @retro.brainstorming?
        current_user_id = @participant&.user_id || Current.user&.id
        base.select { |feedback| feedback.user_id == current_user_id }
      else
        base
      end
    end
  end

  def ungrouped_feedbacks
    split_feedbacks[:ungrouped]
  end

  def grouped_feedbacks_by_group
    groups = split_feedbacks[:grouped].group_by(&:feedback_group)

    if show_vote_results?
      groups.sort_by { |group, _| -group.votes.size }.to_h
    else
      groups
    end
  end

  # Returns all items (groups and ungrouped feedbacks) sorted by votes for voting/discussion phase
  def all_items_sorted_by_votes
    items = []

    # Add groups with their vote counts
    grouped_feedbacks_by_group.each do |group, group_feedbacks|
      items << { type: :group, group: group, feedbacks: group_feedbacks, votes: group.votes.size }
    end

    # Add ungrouped feedbacks with their vote counts
    ungrouped_feedbacks.each do |feedback|
      items << { type: :feedback, feedback: feedback, votes: feedback.votes.size }
    end

    # Sort all items by votes descending
    items.sort_by { |item| -item[:votes] }
  end

  def grouping_enabled?
    return false unless @retro.grouping?

    if @participant
      @participant.admin?
    else
      @retro.admin?(Current.user)
    end
  end

  def show_vote_results?
    @retro.voting? || @retro.discussion?
  end

  def voting_enabled?
    @retro.voting?
  end

  def current_participant
    @current_participant ||= @participant || @retro.participants.includes(:votes).find_by(user: Current.user)
  end

  def has_feedbacks?
    return @has_feedbacks unless @has_feedbacks.nil?

    if @preloaded_feedbacks
      feedbacks.any?
    else
      categories_with_feedbacks.include?(@category)
    end
  end

  def title
    @title.presence || @retro.column_name_for(@category)
  end

  def highlight_color
    HIGHLIGHT_COLORS[@position % HIGHLIGHT_COLORS.length]
  end

  def categories_with_feedbacks
    cache_key = if @retro.brainstorming?
      :@_published_feedback_categories_for_current_user
    else
      :@_published_feedback_categories
    end

    @retro.instance_variable_get(cache_key) || @retro.instance_variable_set(cache_key, begin
      scope = @retro.feedbacks.published
      scope = scope.where(user_id: @participant&.user_id || Current.user&.id) if @retro.brainstorming?
      scope.distinct.pluck(:category)
    end)
  end

  def feedback_records
    @feedback_records ||= feedbacks.is_a?(ActiveRecord::Relation) ? feedbacks.to_a : feedbacks
  end

  def split_feedbacks
    @split_feedbacks ||= begin
      grouped, ungrouped = feedback_records.partition { |feedback| feedback.feedback_group_id.present? }
      { grouped:, ungrouped: }
    end
  end
end

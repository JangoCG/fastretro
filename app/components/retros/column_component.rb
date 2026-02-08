class Retros::ColumnComponent < ApplicationComponent
  TITLES = {
    "went_well" => "What went well",
    "could_be_better" => "What could be better"
  }.freeze

  HEADER_STYLES = {
    "went_well" => "bg-emerald-500 dark:bg-emerald-600 text-white",
    "could_be_better" => "bg-amber-500 dark:bg-amber-600 text-white"
  }.freeze

  BORDER_STYLES = {
    "went_well" => "border-emerald-200 dark:border-emerald-500/50",
    "could_be_better" => "border-amber-200 dark:border-amber-500/50"
  }.freeze

  def initialize(retro:, category:)
    @retro = retro
    @category = category
  end

  private

  def feedbacks
    @feedbacks ||= begin
      base = @retro.feedbacks.published.in_category(@category)
      if @retro.brainstorming?
        base.where(user: Current.user)
      else
        base
      end
    end
  end

  def ungrouped_feedbacks
    base = feedbacks.where(feedback_group_id: nil)
    if show_vote_results?
      sort_by_votes(base)
    else
      base
    end
  end

  def grouped_feedbacks_by_group
    groups = feedbacks.where.not(feedback_group_id: nil).group_by(&:feedback_group)
    if show_vote_results?
      groups.sort_by { |group, _| -group.votes.count }.to_h
    else
      groups
    end
  end

  # Returns all items (groups and ungrouped feedbacks) sorted by votes for voting phase
  def all_items_sorted_by_votes
    items = []

    # Add groups with their vote counts
    grouped_feedbacks_by_group.each do |group, group_feedbacks|
      items << { type: :group, group: group, feedbacks: group_feedbacks, votes: group.votes.count }
    end

    # Add ungrouped feedbacks with their vote counts
    ungrouped_feedbacks.each do |feedback|
      items << { type: :feedback, feedback: feedback, votes: feedback.votes.count }
    end

    # Sort all items by votes descending
    items.sort_by { |item| -item[:votes] }
  end

  def grouping_enabled?
    @retro.grouping? && @retro.admin?(Current.user)
  end

  def show_vote_results?
    @retro.voting? || @retro.discussion?
  end

  def voting_enabled?
    @retro.voting?
  end

  def current_participant
    @current_participant ||= @retro.participants.find_by(user: Current.user)
  end

  def sort_by_votes(feedbacks)
    feedbacks.left_joins(:votes)
             .group(:id)
             .order("COUNT(votes.id) DESC")
  end

  def title
    TITLES[@category]
  end

  def emoji
    EMOJIS[@category]
  end

  def header_style
    HEADER_STYLES[@category]
  end

  def border_style
    BORDER_STYLES[@category]
  end
end

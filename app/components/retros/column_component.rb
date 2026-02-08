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

  def initialize(retro:, category:, participant: nil)
    @retro = retro
    @category = category
    @participant = participant
  end

  private

  def feedbacks
    @feedbacks ||= begin
      base = @retro.feedbacks.published.in_category(@category).includes(:user, :rich_text_content)
      base = base.includes(:votes, feedback_group: :votes) if show_vote_results?
      if @retro.brainstorming?
        base.where(user: Current.user)
      else
        base
      end
    end
  end

  def ungrouped_feedbacks
    feedbacks.where(feedback_group_id: nil)
  end

  def grouped_feedbacks_by_group
    groups = feedbacks.where.not(feedback_group_id: nil).group_by(&:feedback_group)
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
    @retro.grouping? && @retro.admin?(Current.user)
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

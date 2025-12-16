class Retros::RetroCardComponent < ApplicationComponent
  COLORS = {
    "blue" => { card_bg: "bg-blue-50 dark:bg-blue-900/20", border: "border-blue-200 dark:border-blue-800", tag_bg: "bg-blue-500", text: "text-blue-600 dark:text-blue-400" },
    "green" => { card_bg: "bg-green-50 dark:bg-green-900/20", border: "border-green-200 dark:border-green-800", tag_bg: "bg-green-500", text: "text-green-600 dark:text-green-400" },
    "yellow" => { card_bg: "bg-yellow-50 dark:bg-yellow-900/20", border: "border-yellow-200 dark:border-yellow-800", tag_bg: "bg-yellow-500", text: "text-yellow-600 dark:text-yellow-400" },
    "purple" => { card_bg: "bg-purple-50 dark:bg-purple-900/20", border: "border-purple-200 dark:border-purple-800", tag_bg: "bg-purple-500", text: "text-purple-600 dark:text-purple-400" },
    "pink" => { card_bg: "bg-pink-50 dark:bg-pink-900/20", border: "border-pink-200 dark:border-pink-800", tag_bg: "bg-pink-500", text: "text-pink-600 dark:text-pink-400" },
    "orange" => { card_bg: "bg-orange-50 dark:bg-orange-900/20", border: "border-orange-200 dark:border-orange-800", tag_bg: "bg-orange-500", text: "text-orange-600 dark:text-orange-400" }
  }.freeze

  def initialize(retro:)
    @retro = retro
  end

  private

  def feedback_count
    @retro.feedbacks.published.count
  end

  def color_key
    COLORS.keys[@retro.id % COLORS.size]
  end

  def card_bg_class
    COLORS[color_key][:card_bg]
  end

  def border_class
    COLORS[color_key][:border]
  end

  def tag_bg_class
    COLORS[color_key][:tag_bg]
  end

  def text_class
    COLORS[color_key][:text]
  end
end

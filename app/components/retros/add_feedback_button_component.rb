class Retros::AddFeedbackButtonComponent < ApplicationComponent
  HOTKEY_POOL = ("a".."z").to_a + ("1".."9").to_a + [ "0" ]

  def initialize(retro:, category:)
    @retro = retro
    @category = category
  end

  private

  def hotkey
    @hotkey ||= hotkeys_by_category[@category.to_s]&.upcase
  end

  def hotkey_action
    return unless hotkey

    "keydown.#{hotkey.downcase}@document->hotkey#click"
  end

  def hotkey_data
    return {} unless hotkey_action

    { controller: "hotkey", action: hotkey_action }
  end

  def hotkeys_by_category
    @hotkeys_by_category ||= begin
      assigned_keys = []

      @retro.column_categories.index_with do |category|
        preferred_keys_for(category).find do |key|
          next if assigned_keys.include?(key)

          assigned_keys << key
          true
        end
      end
    end
  end

  def preferred_keys_for(category)
    category.to_s
      .downcase
      .scan(/[a-z0-9]/)
      .uniq
      .then { |keys| keys + (HOTKEY_POOL - keys) }
  end
end

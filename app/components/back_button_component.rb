class BackButtonComponent < ApplicationComponent
  def initialize(label:, href:, hotkeys: [ "esc" ])
    @label = label
    @href = href
    @hotkeys = Array(hotkeys)
  end

  def call
    link_to @href, class: "group inline-flex items-center gap-2 font-mono text-xs sm:text-sm font-bold uppercase hover:bg-black hover:text-white px-2 sm:px-3 py-1.5 sm:py-2 transition-colors border border-transparent hover:border-black", data: hotkey_data do
      safe_join([
        content_tag(:span, "← #{@label.upcase}", class: "sm:hidden"),
        content_tag(:span, "RETURN_TO_#{@label.upcase}", class: "hidden sm:inline"),
        content_tag(:span, helpers.render(KbdComponent.new(key: "Esc", size: :sm)), class: "hidden sm:inline")
      ])
    end
  end

  private

  def hotkey_data
    {
      controller: "hotkey",
      action: @hotkeys.map { |key| "keydown.#{key}@document->hotkey#click" }.join(" ")
    }
  end
end

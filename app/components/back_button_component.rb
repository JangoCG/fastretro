class BackButtonComponent < ApplicationComponent
  def initialize(label:, href:, hotkeys: [ "esc" ], variant: :default)
    @label = label
    @href = href
    @hotkeys = Array(hotkeys)
    @variant = variant.to_sym
  end

  def call
    return fizzy_back_button if @variant == :fizzy

    default_back_button
  end

  private

  def default_back_button
    link_to @href, class: "group inline-flex items-center gap-2 font-mono text-xs sm:text-sm font-bold uppercase hover:bg-black hover:text-white px-2 sm:px-3 py-1.5 sm:py-2 transition-colors border border-transparent hover:border-black", data: hotkey_data do
      safe_join([
        content_tag(:span, "← #{@label.upcase}", class: "sm:hidden"),
        content_tag(:span, "RETURN_TO_#{@label.upcase}", class: "hidden sm:inline"),
        content_tag(:span, helpers.render(KbdComponent.new(key: "Esc", size: :sm)), class: "hidden sm:inline")
      ])
    end
  end

  def fizzy_back_button
    link_to @href, class: "inline-flex items-center gap-2 text-zinc-500 hover:text-zinc-900 transition-colors group", data: hotkey_data do
      safe_join([
        icon_tag("arrow-left", class: "text-lg group-hover:-translate-x-1 transition-transform"),
        content_tag(:span, "RETURN TO #{normalized_label}", class: "text-xs font-bold uppercase tracking-wide")
      ])
    end
  end

  def normalized_label
    @label.to_s.tr("_", " ").upcase
  end

  def hotkey_data
    {
      controller: "hotkey",
      action: @hotkeys.map { |key| "keydown.#{key}@document->hotkey#click" }.join(" ")
    }
  end
end

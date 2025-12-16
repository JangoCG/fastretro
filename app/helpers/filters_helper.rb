module FiltersHelper
  def filter_place_menu_item(path, label, icon, new_window: false, current: false, turbo: true)
    link_to_params = {}
    link_to_params.merge!({ target: "_blank" }) if new_window
    link_to_params.merge!({ data: { turbo: false } }) unless turbo

    tag.li class: "flex items-center gap-2 rounded-lg hover:bg-gray-100", id: "filter-place-#{label.parameterize}", data: { filter_target: "item", navigable_list_target: "item" }, aria: { checked: current } do
      concat icon_tag(icon, class: "w-5 h-5 text-gray-500 shrink-0")
      concat(link_to(path, link_to_params.merge(class: "flex-1 py-2 pr-3 truncate flex items-center"), data: { turbo: turbo }) do
        concat tag.span(label, class: "truncate")
        concat icon_tag("check", class: "w-4 h-4 ml-auto text-green-600 #{current ? '' : 'hidden'}", "aria-hidden": true) if current
      end)
    end
  end

  def filter_dialog(label, &block)
    tag.dialog class: "mt-2 p-4 bg-white rounded-xl shadow-lg flex flex-col items-start gap-2 text-sm", data: {
      action: "turbo:before-cache@document->dialog#close keydown->navigable-list#navigate filter:changed->navigable-list#reset toggle->filter#filter",
      aria: { label: label, aria_description: label },
      controller: "navigable-list",
      dialog_target: "dialog",
      navigable_list_focus_on_selection_value: false,
      navigable_list_actionable_items_value: true
    }, &block
  end

  def collapsible_nav_section(title, **properties, &block)
    tag.details class: "group", data: { action: "toggle->nav-section-expander#toggle", nav_section_expander_target: "section", nav_section_expander_key_value: title.parameterize }, open: true, **properties do
      concat(tag.summary(class: "flex items-center gap-1 py-2 text-sm font-semibold text-gray-600 cursor-pointer select-none hover:text-gray-900") do
        concat icon_tag("caret-down", class: "transition-transform group-open:rotate-0 -rotate-90")
        concat title
      end)
      concat(tag.ul(class: "space-y-1") do
        capture(&block)
      end)
    end
  end

  def filter_hotkey_link(title, path, key, icon)
    # Industrial "Function Key" styling
    # - Base: White with thick zinc border and hard shadow
    # - Hover/Active: Physically moves down-right to simulate a mechanical press
    # - Aria-Selected: Inverts to Black/White for high-contrast focus state
    button_classes = "group relative flex flex-col items-center justify-center gap-1 sm:gap-2 p-3 sm:p-4 rounded-[2px] border-[2px] border-zinc-900 bg-white text-zinc-900 shadow-[4px_4px_0px_0px_rgba(24,24,27,1)] hover:shadow-[1px_1px_0px_0px_rgba(24,24,27,1)] hover:translate-x-[3px] hover:translate-y-[3px] active:translate-x-[4px] active:translate-y-[4px] active:shadow-none aria-selected:bg-zinc-900 aria-selected:text-[#F8F5EC] aria-selected:shadow-none aria-selected:translate-x-[4px] aria-selected:translate-y-[4px] transition-all duration-75 outline-none"

    link_to path, class: button_classes, id: "filter-hotkey-#{key}", role: "listitem", data: { filter_target: "item", navigable_list_target: "item", controller: "hotkey", action: "keydown.#{key}@document->hotkey#click keydown.shift+#{key}@document->hotkey#click" } do
      # KBD: Styled as a small technical label in the corner
      # Inverts colors when the parent is selected
      concat tag.kbd(key, class: "hidden sm:flex items-center justify-center absolute top-1.5 right-1.5 w-5 h-5 text-[10px] font-mono font-bold text-zinc-500 group-hover:text-zinc-900 group-aria-selected:text-zinc-900 bg-zinc-100 group-aria-selected:bg-white border border-zinc-300 rounded-[1px] transition-colors")

      # Icon: Bold and sharp
      concat icon_tag(icon, class: "text-zinc-900 group-aria-selected:text-[#F8F5EC] text-xl sm:text-2xl transition-colors")

      # Title: Uppercase and heavy
      concat tag.span(title.html_safe, class: "text-[0.6rem] sm:text-xs font-black uppercase tracking-tight text-zinc-900 group-aria-selected:text-[#F8F5EC] text-center leading-none transition-colors")
    end
  end
end

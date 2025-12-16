module My::MenuHelper
  def jump_field_tag
    text_field_tag :search, nil,
      type: "search",
      role: "combobox",
      placeholder: "Type to jump to a person or account…",
      class: "w-full px-4 py-3.5 text-base border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500 rounded-xl focus:border-blue-400 dark:focus:border-blue-500 focus:ring-2 focus:ring-blue-100 dark:focus:ring-blue-900 focus:outline-none transition-colors",
      autofocus: true,
      autocorrect: "off",
      autocomplete: "off",
      aria: { activedescendant: "" },
      data: {
        "1p-ignore": "true",
        filter_target: "input",
        nav_section_expander_target: "input",
        navigable_list_target: "input",
        action: "input->filter#filter" }
  end

  def menu_user_item(user)
    menu_item("person", user) do
      link_to(tag.span(user.name, class: "truncate"), user, class: "flex-1 py-2 pr-3 truncate")
    end
  end

  def menu_item(item, record)
    tag.li(class: "flex items-center gap-2 rounded-lg hover:bg-gray-100", data: { filter_target: "item", navigable_list_target: "item", id: "filter-#{item}-#{record.id}" }) do
      icon_tag(item, class: "w-5 h-5 text-gray-500 shrink-0") + yield
    end
  end
end

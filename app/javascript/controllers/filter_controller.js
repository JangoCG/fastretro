import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/timing_helpers"
import { filterMatches } from "helpers/text_helpers"

export default class extends Controller {
  static targets = [ "input", "item", "section", "blankSlate" ]

  initialize() {
    this.filter = debounce(this.filter.bind(this), 100)
  }

  filter() {
    const query = this.inputTarget.value

    this.itemTargets.forEach(item => {
      if (filterMatches(item.textContent, query)) {
        item.removeAttribute("hidden")
      } else {
        item.toggleAttribute("hidden", true)
      }
    })

    this.#updateSectionVisibility()
    this.#updateBlankSlateVisibility()

    this.dispatch("changed")
  }

  clearInput() {
    if (!this.hasInputTarget) return
    this.inputTarget.value = ""
  }

  #updateSectionVisibility() {
    this.sectionTargets.forEach(section => {
      const items = section.querySelectorAll("[data-filter-target='item']")
      const hasVisibleItems = Array.from(items).some(item => !item.hidden)
      section.toggleAttribute("hidden", !hasVisibleItems)
    })
  }

  #updateBlankSlateVisibility() {
    if (!this.hasBlankSlateTarget) return

    const hasAnyVisibleItems = this.itemTargets.some(item => !item.hidden)
    this.blankSlateTarget.classList.toggle("hidden", hasAnyVisibleItems)
  }
}

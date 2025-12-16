import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { key: String }
  static targets = [ "input", "section" ]

  sectionTargetConnected() {
    this.#restoreToggles()
  }

  toggle(event) {
    const section = event.target
    if (section.hasAttribute("data-is-filtering")) return

    const key = this.#localStorageKeyFor(section)
    if (section.open) {
      localStorage.removeItem(key)
    } else {
      localStorage.setItem(key, true)
    }
  }

  showWhileFiltering() {
    if (this.inputTarget.value) {
      this.#expandAll();
    } else {
      this.#restoreToggles()
    }
  }

  #expandAll() {
    this.sectionTargets.forEach(section => {
      section.setAttribute("data-is-filtering", true)
      section.open = true
    })
  }

  #restoreToggles() {
    this.sectionTargets.forEach(section => {
      const key = this.#localStorageKeyFor(section)
      section.open = !localStorage.getItem(key)
      section.removeAttribute("data-is-filtering")
    })
  }

  #localStorageKeyFor(section) {
    return section.getAttribute("data-nav-section-expander-key-value")
  }
}

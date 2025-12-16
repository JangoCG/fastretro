import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click(event) {
    if (this.#isClickable && !this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  submit(event) {
    if (!this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }

  focus(event) {
    if (this.#isClickable && !this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.focus()
    }
  }

  #shouldIgnore(event) {
    // Allow ESC key to work even in inputs
    if (event.key === "Escape") return false
    // Allow Ctrl/Cmd+Enter shortcuts to work in editors for form submission
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) return false
    // Ignore when typing in inputs, textareas, or lexxy editor
    return event.defaultPrevented || event.target.closest("input, textarea, [contenteditable], lexxy-editor")
  }

  get #isClickable() {
    return getComputedStyle(this.element).pointerEvents !== "none"
  }
}

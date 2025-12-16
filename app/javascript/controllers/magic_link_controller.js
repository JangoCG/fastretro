import { Controller } from "@hotwired/stimulus"

// Handles magic link code input auto-submission
export default class extends Controller {
  static targets = ["input"]

  submitOnEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.submit()
    }
  }

  submitOnPaste(event) {
    // Wait for paste to complete, then submit if we have 6 characters
    setTimeout(() => {
      const value = this.inputTarget.value.trim()
      if (value.length === 6) {
        this.submit()
      }
    }, 0)
  }

  submit() {
    this.element.requestSubmit()
  }
}

import { Controller } from "@hotwired/stimulus"

// Copies text to clipboard with visual feedback
// Supports two modes:
// 1. Icon mode: uses icon/check targets to show checkmark
// 2. Button mode: uses source/button targets to show "Copied!" text
export default class extends Controller {
  static targets = ["icon", "check", "source", "button"]
  static values = { text: String }

  async copy() {
    const text = this.hasSourceTarget ? this.sourceTarget.value : this.textValue
    await navigator.clipboard.writeText(text)

    if (this.hasIconTarget && this.hasCheckTarget) {
      this.#showIconFeedback()
    } else if (this.hasButtonTarget) {
      this.#showButtonFeedback()
    }
  }

  #showIconFeedback() {
    this.iconTarget.style.display = "none"
    this.checkTarget.style.display = ""

    setTimeout(() => {
      this.checkTarget.style.display = "none"
      this.iconTarget.style.display = ""
    }, 2000)
  }

  #showButtonFeedback() {
    const originalText = this.buttonTarget.textContent
    this.buttonTarget.textContent = "Copied!"

    setTimeout(() => {
      this.buttonTarget.textContent = originalText
    }, 2000)
  }
}

import { Controller } from "@hotwired/stimulus"

// Copies text to clipboard with icon feedback
export default class extends Controller {
  static targets = ["icon", "check"]
  static values = { text: String }

  async copy() {
    await navigator.clipboard.writeText(this.textValue)

    this.iconTarget.style.display = "none"
    this.checkTarget.style.display = ""

    setTimeout(() => {
      this.checkTarget.style.display = "none"
      this.iconTarget.style.display = ""
    }, 2000)
  }
}

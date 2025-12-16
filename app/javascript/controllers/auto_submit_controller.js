import { Controller } from "@hotwired/stimulus"

// Auto-submits forms on page load (for session transfers, verifications, etc.)
export default class extends Controller {
  connect() {
    this.element.requestSubmit()
  }
}

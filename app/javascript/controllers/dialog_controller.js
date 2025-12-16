import { Controller } from "@hotwired/stimulus"
import { orient } from "helpers/orientation_helpers"

export default class extends Controller {
  static targets = [ "dialog" ]
  static values = {
    modal: { type: Boolean, default: false },
    sizing: { type: Boolean, default: true }
  }

  connect() {
    this.dialogTarget.setAttribute("aria-hidden", "true")
    this.boundHandleEscape = this.handleEscape.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleEscape, true)
  }

  open() {
    const modal = this.modalValue

    if (modal) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.show()
      orient(this.dialogTarget)
    }

    // Add document-level ESC handler with capture phase for priority
    document.addEventListener("keydown", this.boundHandleEscape, true)

    this.loadLazyFrames()
    this.dialogTarget.setAttribute("aria-hidden", "false")
    this.dispatch("show")
  }

  toggle() {
    if (this.dialogTarget.open) {
      this.close()
    } else {
      this.open()
    }
  }

  close() {
    // Remove document-level ESC handler
    document.removeEventListener("keydown", this.boundHandleEscape, true)

    this.dialogTarget.close()
    this.dialogTarget.setAttribute("aria-hidden", "true")
    this.dialogTarget.blur()
    orient(this.dialogTarget, false)
    this.dispatch("close")
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.dialogTarget.open) {
      event.preventDefault()
      event.stopPropagation()
      this.close()
    }
  }

  closeOnClickOutside({ target }) {
    if (!this.element.contains(target)) this.close()
  }

  preventCloseOnMorphing(event) {
    if (event.detail?.attributeName === "open") {
      event.preventDefault()
      event.stopPropagation()
    }
  }

  loadLazyFrames() {
    Array.from(this.dialogTarget.querySelectorAll("turbo-frame")).forEach(frame => { frame.loading = "eager" })
  }

  captureKey(event) {
    if (event.key !== "Escape") { event.stopPropagation() }
  }
}

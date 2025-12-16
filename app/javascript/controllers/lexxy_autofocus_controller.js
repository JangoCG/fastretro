import { Controller } from "@hotwired/stimulus"

// Automatically focuses a lexxy-editor when the page loads
export default class extends Controller {
  connect() {
    // Wait for the lexxy editor to initialize
    this.focusEditor()
  }

  focusEditor() {
    const editor = this.element.querySelector("lexxy-editor")
    if (!editor) return

    // The contenteditable div is created by lexxy inside the custom element
    const contentEditable = editor.querySelector("[contenteditable='true']")
    if (contentEditable) {
      contentEditable.focus()
    } else {
      // If not yet rendered, wait a bit and retry
      requestAnimationFrame(() => {
        const contentEditable = editor.querySelector("[contenteditable='true']")
        if (contentEditable) {
          contentEditable.focus()
        }
      })
    }
  }
}

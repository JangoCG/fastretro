import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  static targets = ["container"]

  connect() {
    // Set up listener for Turbo Stream custom events
    document.addEventListener("turbo:highlight-update", this.handleHighlightUpdate.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:highlight-update", this.handleHighlightUpdate.bind(this))
  }

  toggle(event) {
    const userId = event.currentTarget.dataset.userId
    const container = document.getElementById("retro-content-grid")
    const currentHighlight = container?.dataset.highlightedUserId

    // Toggle: if same user, clear; otherwise set new
    const newHighlight = currentHighlight === userId ? null : userId

    // Update UI immediately for responsive feel
    this.applyHighlight(newHighlight)

    // Persist to server (will broadcast to other clients)
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ user_id: userId })
    })
  }

  handleHighlightUpdate(event) {
    this.applyHighlight(event.detail.userId)
  }

  applyHighlight(userId) {
    const container = document.getElementById("retro-content-grid")
    if (!container) return

    // Update container attribute
    if (userId) {
      container.dataset.highlightedUserId = userId
    } else {
      delete container.dataset.highlightedUserId
    }

    // Update all feedback cards
    container.querySelectorAll("[data-user-id]").forEach(el => {
      if (userId && el.dataset.userId === userId) {
        el.dataset.highlighted = "true"
      } else {
        delete el.dataset.highlighted
      }
    })

    // Update participant list selection
    document.querySelectorAll("[data-user-id]").forEach(el => {
      if (el.closest("li")) {
        if (userId && el.dataset.userId === userId) {
          el.closest("li")?.setAttribute("aria-selected", "true")
        } else {
          el.closest("li")?.removeAttribute("aria-selected")
        }
      }
    })
  }
}

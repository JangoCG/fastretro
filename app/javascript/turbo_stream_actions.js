import { Turbo } from "@hotwired/turbo-rails"

// Custom Turbo Stream action to redirect all connected clients
Turbo.StreamActions.redirect = function() {
  console.log("[Turbo] Redirect action received", this)
  const url = this.getAttribute("url")
  console.log("[Turbo] Redirecting to:", url)
  if (url) {
    Turbo.visit(url, { action: "replace" })
  }
}

// Custom Turbo Stream action to update participant highlight without full page refresh
Turbo.StreamActions.highlight = function() {
  const userId = this.getAttribute("user-id")
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
  document.querySelectorAll("li[data-user-id]").forEach(li => {
    if (userId && li.dataset.userId === userId) {
      li.setAttribute("aria-selected", "true")
    } else {
      li.removeAttribute("aria-selected")
    }
  })
}

import { Turbo } from "@hotwired/turbo-rails"

// Custom Turbo Stream action to redirect all connected clients
Turbo.StreamActions.redirect = function() {
  const url = this.getAttribute("url")
  if (url) {
    const targetPath = new URL(url, window.location.origin).pathname
    if (window.location.pathname !== targetPath) {
      Turbo.visit(url, { action: "replace" })
    }
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

// Custom Turbo Stream action to control elevator music across all connected clients
Turbo.StreamActions.music = function() {
  const state = this.getAttribute("state")
  const audio = document.getElementById("elevator-music-audio")
  const toggleButton = document.getElementById("music-toggle-button")
  const enablePrompt = document.getElementById("music-enable-prompt")

  if (!audio) return

  if (state === "playing") {
    audio.play().then(() => {
      // Autoplay worked, hide prompt if visible
      if (enablePrompt) enablePrompt.classList.add("hidden")
      if (toggleButton) toggleButton.dataset.playing = "true"
    }).catch(e => {
      console.log("[Music] Autoplay blocked:", e)
      // Show prompt for users to click to enable audio
      if (enablePrompt) enablePrompt.classList.remove("hidden")
    })
  } else {
    audio.pause()
    if (toggleButton) delete toggleButton.dataset.playing
    if (enablePrompt) enablePrompt.classList.add("hidden")
  }
}

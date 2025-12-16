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

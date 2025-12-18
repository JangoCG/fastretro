import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    completed: Boolean
  }

  connect() {
    this.updateVisuals()
  }

  async toggle(event) {
    event.preventDefault()

    // Optimistic update for immediate feedback
    this.completedValue = !this.completedValue
    this.updateVisuals()

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (!response.ok) {
        // Revert on failure
        this.completedValue = !this.completedValue
        this.updateVisuals()
      }
    } catch (error) {
      console.error("Failed to toggle action completion:", error)
      // Revert on error
      this.completedValue = !this.completedValue
      this.updateVisuals()
    }
  }

  updateVisuals() {
    const card = this.element.querySelector("div[class*='bg-']")
    const checkbox = this.element.querySelector("button")
    const content = this.element.querySelector(".rich-text-content").parentElement
    const indicator = this.element.querySelector(".w-1\\.5")
    const footer = this.element.querySelector("div.px-4.py-3")

    if (this.completedValue) {
      // Mark as completed
      card.classList.remove("bg-violet-50")
      card.classList.add("bg-emerald-50", "opacity-75")
      checkbox.classList.remove("bg-white")
      checkbox.classList.add("bg-emerald-500")
      checkbox.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white font-black" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="4"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>'
      content.classList.add("line-through", "opacity-60")
      indicator?.classList.remove("bg-violet-400")
      indicator?.classList.add("bg-emerald-400")

      // Add DONE badge if it doesn't exist
      if (!footer.querySelector(".text-emerald-700")) {
        const badge = document.createElement("span")
        badge.className = "text-[0.6rem] font-bold text-emerald-700 uppercase tracking-wider px-2 py-1 bg-emerald-200 border border-emerald-400"
        badge.textContent = "DONE"
        footer.appendChild(badge)
      }
    } else {
      // Mark as incomplete
      card.classList.remove("bg-emerald-50", "opacity-75")
      card.classList.add("bg-violet-50")
      checkbox.classList.remove("bg-emerald-500")
      checkbox.classList.add("bg-white")
      checkbox.innerHTML = ""
      content.classList.remove("line-through", "opacity-60")
      indicator?.classList.remove("bg-emerald-400")
      indicator?.classList.add("bg-violet-400")

      // Remove DONE badge if it exists
      const badge = footer.querySelector(".text-emerald-700")
      if (badge) {
        badge.remove()
      }
    }
  }
}

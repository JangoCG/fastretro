import { Controller } from "@hotwired/stimulus"

/**
 * Automatically re-sorts feedback cards by vote count when votes change.
 *
 * Usage:
 *   <div data-controller="vote-sorting">
 *     <div data-vote-sorting-target="item">
 *       <!-- card with vote count inside -->
 *     </div>
 *   </div>
 *
 * The controller watches for changes to [data-vote-total] elements and
 * re-sorts the items by their vote counts (descending).
 */
export default class extends Controller {
  static targets = ["item"]

  connect() {
    // Observe DOM changes to detect vote count updates
    this.observer = new MutationObserver(this.handleMutations.bind(this))

    // Observe the entire controller element for changes to data-vote-total
    this.observer.observe(this.element, {
      childList: true,
      subtree: true,
      characterData: true,
      characterDataOldValue: true
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleMutations(mutations) {
    // Check if any mutation affected a vote-total element
    const voteCountChanged = mutations.some(mutation => {
      // Text content changed inside a vote-total element
      if (mutation.type === "characterData") {
        return mutation.target.parentElement?.hasAttribute("data-vote-total")
      }

      // Child elements added/removed (could be vote count replacement)
      if (mutation.type === "childList") {
        const target = mutation.target
        return target.hasAttribute?.("data-vote-total") ||
               target.querySelector?.("[data-vote-total]") ||
               target.id?.startsWith("vote_count_")
      }

      return false
    })

    if (voteCountChanged) {
      // Debounce to avoid sorting multiple times for rapid updates
      clearTimeout(this.sortTimeout)
      this.sortTimeout = setTimeout(() => this.sort(), 50)
    }
  }

  sort() {
    const items = this.itemTargets

    if (items.length < 2) return

    // Get vote counts for each item
    const itemsWithCounts = items.map(item => {
      const voteElement = item.querySelector("[data-vote-total]")
      const count = voteElement ? parseInt(voteElement.textContent, 10) || 0 : 0
      return { element: item, count }
    })

    // Sort by vote count descending
    itemsWithCounts.sort((a, b) => b.count - a.count)

    // Check if order actually changed
    const currentOrder = items.map(item => item)
    const newOrder = itemsWithCounts.map(item => item.element)

    const orderChanged = currentOrder.some((item, index) => item !== newOrder[index])

    if (!orderChanged) return

    // Animate and reorder
    // First, add a transition class
    items.forEach(item => {
      item.style.transition = "transform 0.3s ease-out, opacity 0.3s ease-out"
    })

    // Reorder DOM elements
    const container = this.element
    itemsWithCounts.forEach(({ element }) => {
      container.appendChild(element)
    })

    // Clean up transition styles after animation
    setTimeout(() => {
      items.forEach(item => {
        item.style.transition = ""
      })
    }, 300)
  }
}

import { Controller } from "@hotwired/stimulus"

// Stops event propagation - useful for preventing clicks from bubbling up
// to parent elements (e.g., action buttons inside a clickable card)
export default class extends Controller {
  stop(event) {
    event.stopPropagation()
  }
}

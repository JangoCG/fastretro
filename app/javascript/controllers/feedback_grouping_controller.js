import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list", "feedback"]
  static values = {
    groupUrl: String
  }

  connect() {
    this.initializeSortable()
    this.setupDropZones()
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  initializeSortable() {
    this.sortable = Sortable.create(this.listTarget, {
      // No shared group - each column is independent
      animation: 150,
      ghostClass: "feedback-ghost",
      dragClass: "feedback-drag",
      chosenClass: "feedback-chosen",
      filter: ".no-drag",
      draggable: "[data-feedback-id]",
      onStart: this.handleStart.bind(this),
      onMove: this.handleMove.bind(this),
      onEnd: this.handleDrop.bind(this)
    })
  }

  handleStart(event) {
    // Add chosen styling manually since Sortable can't handle multiple classes
    event.item.classList.add("ring-2", "ring-yellow-400")
  }

  setupDropZones() {
    // No-op: visual feedback is now handled in handleMove
  }

  handleMove(event) {
    const draggedEl = event.dragged
    const related = event.related

    // Clear previous hover states from all targets
    this.feedbackTargets.forEach(el => {
      if (el !== draggedEl) {
        el.classList.remove("ring-2", "ring-yellow-400", "scale-105")
      }
    })

    // Only allow grouping with targets in the same list (same column)
    const isInSameList = related && this.listTarget.contains(related)

    if (isInSameList && related !== draggedEl && related.dataset.feedbackId) {
      // Store the element we're hovering over for grouping
      this.potentialTarget = related
      // Add hover state to the current target
      related.classList.add("ring-2", "ring-yellow-400", "scale-105")
    } else {
      // Clear potential target if not in same list
      this.potentialTarget = null
    }

    // Return false to prevent Sortable from reordering items in the DOM
    // We only use drag-drop for grouping, not for reordering
    return false
  }

  handleDrop(event) {
    const draggedEl = event.item
    const draggedId = draggedEl.dataset.feedbackId

    // Clean up visual feedback from dragged item
    draggedEl.classList.remove("ring-2", "ring-yellow-400")

    // Clean up visual feedback from all targets
    this.feedbackTargets.forEach(el => {
      el.classList.remove("ring-2", "ring-yellow-400", "scale-105")
    })

    // Don't allow dragging groups (only individual feedbacks can be dragged)
    if (draggedId.startsWith("group-")) {
      this.potentialTarget = null
      return
    }

    // Check if drop occurred over the potential target
    // Use the drop coordinates to verify we're actually over the target
    if (this.potentialTarget && this.potentialTarget !== draggedEl) {
      const targetId = this.potentialTarget.dataset.feedbackId
      const targetRect = this.potentialTarget.getBoundingClientRect()
      const dropX = event.originalEvent?.clientX || 0
      const dropY = event.originalEvent?.clientY || 0

      // Only group if the drop position is actually within the target's bounds
      const isOverTarget = dropX >= targetRect.left &&
                           dropX <= targetRect.right &&
                           dropY >= targetRect.top &&
                           dropY <= targetRect.bottom

      // Don't group with self, and ensure drop is over target
      if (targetId && targetId !== draggedId && isOverTarget) {
        this.groupFeedbacks(draggedId, targetId)
      }
    }

    this.potentialTarget = null
  }

  groupFeedbacks(sourceId, targetId) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.groupUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({
        source_feedback_id: sourceId,
        target_feedback_id: targetId
      })
    }).then(response => {
      if (response.ok) {
        return response.text()
      }
      throw new Error("Failed to group feedbacks")
    }).then(html => {
      Turbo.renderStreamMessage(html)
    }).catch(error => {
      console.error("Error grouping feedbacks:", error)
    })
  }
}

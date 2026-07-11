import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list", "feedback"]
  static values = {
    groupUrl: String,
    moveUrl: String,
    groupName: String,
    groupingEnabled: Boolean
  }

  connect() {
    this.initializeSortable()
    this.setupDropZones()
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }

    this.clearDropColumnHighlights()
    this.clearDragOrigin()
  }

  initializeSortable() {
    this.sortable = Sortable.create(this.listTarget, {
      group: this.groupNameValue,
      animation: 150,
      scroll: true,
      // Chromium doesn't auto-scroll the window during native HTML5 drags,
      // and Sortable's AutoScroll plugin skips window scrolling unless forced
      forceAutoScrollFallback: true,
      scrollSensitivity: 80,
      scrollSpeed: 15,
      ghostClass: "feedback-ghost",
      dragClass: "feedback-drag",
      chosenClass: "feedback-chosen",
      filter: ".no-drag",
      draggable: "[data-feedback-id]:not([data-feedback-id^='group-'])",
      onStart: this.handleStart.bind(this),
      onMove: this.handleMove.bind(this),
      onEnd: this.handleDrop.bind(this)
    })
  }

  handleStart(event) {
    this.sourceList = event.from
    this.sourceNextSibling = event.item.nextElementSibling

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

    if (event.to !== event.from) {
      this.potentialTarget = null
      this.highlightDropColumn(event.to)
      return true
    }

    this.clearDropColumnHighlights()

    if (!this.groupingEnabledValue) {
      this.potentialTarget = null
      return false
    }

    // Grouping only applies to targets in the source column.
    const isInSameList = related && event.from.contains(related)

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

  async handleDrop(event) {
    const draggedEl = event.item
    const draggedId = draggedEl.dataset.feedbackId

    // Clean up visual feedback from dragged item
    draggedEl.classList.remove("ring-2", "ring-yellow-400")

    // Clean up visual feedback from all targets
    this.feedbackTargets.forEach(el => {
      el.classList.remove("ring-2", "ring-yellow-400", "scale-105")
    })
    this.clearDropColumnHighlights()

    if (event.to !== event.from) {
      this.potentialTarget = null
      await this.moveFeedback(draggedEl, event.to)
      this.clearDragOrigin()
      return
    }

    if (!this.groupingEnabledValue) {
      this.potentialTarget = null
      this.clearDragOrigin()
      return
    }

    // Don't allow dragging groups (only individual feedbacks can be dragged)
    if (draggedId.startsWith("group-")) {
      this.potentialTarget = null
      this.clearDragOrigin()
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
    this.clearDragOrigin()
  }

  highlightDropColumn(list) {
    this.clearDropColumnHighlights()
    list.closest("[data-feedback-column]")?.classList.add("feedback-column-drop-target")
  }

  clearDropColumnHighlights() {
    const board = this.element.closest("[data-feedback-board]") || document
    board.querySelectorAll("[data-feedback-column]").forEach(column => {
      column.classList.remove("feedback-column-drop-target")
    })
  }

  async moveFeedback(item, targetList) {
    const targetCategory = targetList.dataset.feedbackCategory
    const url = this.moveUrlValue.replace("__id__", item.dataset.feedbackId)
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ category: targetCategory })
      })

      if (!response.ok) throw new Error("Failed to move feedback")
    } catch (error) {
      this.restoreDraggedItem(item)
      console.error("Error moving feedback:", error)
    }
  }

  restoreDraggedItem(item) {
    if (!this.sourceList) return

    if (this.sourceNextSibling?.parentElement === this.sourceList) {
      this.sourceList.insertBefore(item, this.sourceNextSibling)
    } else {
      this.sourceList.append(item)
    }
  }

  clearDragOrigin() {
    this.sourceList = null
    this.sourceNextSibling = null
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

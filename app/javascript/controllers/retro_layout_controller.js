import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["customPanel", "defaultInfo", "columnsContainer", "columnRow", "template"]

  connect() {
    this.toggle()
  }

  toggle() {
    const customSelected = this.currentLayoutMode() === "custom"

    if (this.hasCustomPanelTarget) {
      this.customPanelTarget.classList.toggle("hidden", !customSelected)
    }

    if (this.hasDefaultInfoTarget) {
      this.defaultInfoTarget.classList.toggle("hidden", customSelected)
    }

    if (customSelected && this.columnRowTargets.length === 0) {
      this.addColumn()
    }

    this.updateRemoveButtons()
  }

  addColumn() {
    if (!this.hasTemplateTarget || !this.hasColumnsContainerTarget) return

    const fragment = this.templateTarget.content.cloneNode(true)
    this.columnsContainerTarget.appendChild(fragment)

    const lastRow = this.columnRowTargets[this.columnRowTargets.length - 1]
    const input = lastRow?.querySelector("[name='retro[column_names][]']")
    if (input) input.focus()

    this.updateRemoveButtons()
  }

  removeColumn(event) {
    event.preventDefault()

    const row = event.currentTarget.closest("[data-retro-layout-target='columnRow']")
    if (!row) return

    if (this.columnRowTargets.length <= 1) {
      const input = row.querySelector("[name='retro[column_names][]']")
      if (input) {
        input.value = ""
        input.focus()
      }
      return
    }

    row.remove()
    this.updateRemoveButtons()
  }

  updateRemoveButtons() {
    const disableRemove = this.columnRowTargets.length <= 1

    this.columnRowTargets.forEach((row) => {
      const button = row.querySelector("button[data-action*='retro-layout#removeColumn']")
      if (!button) return

      button.disabled = disableRemove
      button.classList.toggle("opacity-50", disableRemove)
      button.classList.toggle("cursor-not-allowed", disableRemove)
    })
  }

  currentLayoutMode() {
    const checked = this.element.querySelector("input[name='retro[layout_mode]']:checked")
    return checked?.value || "default"
  }
}

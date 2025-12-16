import { Controller } from "@hotwired/stimulus"

const AUTOSAVE_INTERVAL = 2000

export default class extends Controller {
  #timer = null

  disconnect() {
    this.submit()
  }

  change() {
    this.#scheduleSave()
  }

  submit() {
    if (this.#timer) {
      this.#save()
    }
  }

  #scheduleSave() {
    clearTimeout(this.#timer)
    this.#timer = setTimeout(() => this.#save(), AUTOSAVE_INTERVAL)
  }

  #save() {
    clearTimeout(this.#timer)
    this.#timer = null
    this.element.requestSubmit()
  }
}

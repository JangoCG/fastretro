import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    playing: Boolean
  }

  static targets = ["audio", "button", "prompt"]

  connect() {
    // If music was playing when page loaded, try to start it
    if (this.playingValue && this.hasAudioTarget) {
      this.audioTarget.play().then(() => {
        if (this.hasPromptTarget) this.promptTarget.classList.add("hidden")
      }).catch(e => {
        console.log("[Music] Autoplay blocked on connect:", e)
        // Show prompt for user to enable audio
        if (this.hasPromptTarget) this.promptTarget.classList.remove("hidden")
      })
    }
  }

  toggle() {
    const isPlaying = !this.audioTarget.paused

    // Update UI immediately for responsive feel
    if (isPlaying) {
      this.audioTarget.pause()
      if (this.hasButtonTarget) delete this.buttonTarget.dataset.playing
      if (this.hasPromptTarget) this.promptTarget.classList.add("hidden")
    } else {
      this.audioTarget.play().catch(e => console.log("[Music] Autoplay blocked:", e))
      if (this.hasButtonTarget) this.buttonTarget.dataset.playing = "true"
    }

    // Persist to server (will broadcast to other clients)
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
  }

  // Called when participant clicks the "enable audio" prompt
  enableAudio() {
    if (this.hasAudioTarget) {
      this.audioTarget.play().then(() => {
        if (this.hasPromptTarget) this.promptTarget.classList.add("hidden")
        if (this.hasButtonTarget) this.buttonTarget.dataset.playing = "true"
      }).catch(e => console.log("[Music] Still blocked:", e))
    }
  }
}

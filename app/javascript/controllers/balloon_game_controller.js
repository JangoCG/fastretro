import { Controller } from "@hotwired/stimulus"

// Balloon popping game for the complete phase. Balloons float up through the arena,
// clicking one pops it, and pops are batched to the server so a frantic clicker
// doesn't fire a request per balloon. The shared highscore comes back over the
// retro's Turbo Stream, so this controller only tracks the local score.
const COLORS = ["#f43f5e", "#f59e0b", "#22c55e", "#38bdf8", "#a855f7", "#ec4899"]
const SPAWN_INTERVAL = 650
const FLUSH_INTERVAL = 1000
const MAX_BALLOONS = 14
const POP_ANIMATION_MS = 240
const POP_SOUND_SECONDS = 0.12

export default class extends Controller {
  static targets = ["arena", "score"]

  static values = {
    url: String,
    score: Number,
    popLabel: String,
    maxBatch: Number
  }

  connect() {
    this.pendingPops = 0
    this.spawnTimer = setInterval(() => this.spawn(), SPAWN_INTERVAL)
    this.flushTimer = setInterval(() => this.flush(), FLUSH_INTERVAL)
    this.spawn()
  }

  disconnect() {
    clearInterval(this.spawnTimer)
    clearInterval(this.flushTimer)
    this.closeAudio()
    this.flush()
  }

  pop(event) {
    const balloon = event.target.closest(".balloon")
    if (!balloon || balloon.hasAttribute("data-popped")) return

    // Pointer and keyboard both land here (a click follows every pointerdown), so
    // the marker above keeps a single balloon from counting twice.
    balloon.setAttribute("data-popped", "")
    balloon.setAttribute("aria-hidden", "true")
    setTimeout(() => balloon.remove(), POP_ANIMATION_MS)

    this.pendingPops++
    this.scoreValue++
    this.renderScore()
    this.playPopSound()
  }

  renderScore() {
    if (this.hasScoreTarget) this.scoreTarget.textContent = this.scoreValue
  }

  // The pop is synthesized instead of shipped as an audio file: a short burst of
  // decaying noise for the bang, plus a quick downward blip for its body. Only your
  // own clicks make a sound, so a room full of players stays bearable.
  playPopSound() {
    const audio = this.audioContext()
    if (!audio) return

    const startedAt = audio.currentTime
    const volume = audio.createGain()
    volume.gain.setValueAtTime(0.3, startedAt)
    volume.gain.exponentialRampToValueAtTime(0.001, startedAt + POP_SOUND_SECONDS)
    volume.connect(audio.destination)

    const bang = audio.createBufferSource()
    bang.buffer = this.noiseBuffer(audio)
    const band = audio.createBiquadFilter()
    band.type = "bandpass"
    band.frequency.value = 1400
    bang.connect(band).connect(volume)
    bang.start(startedAt)

    const blip = audio.createOscillator()
    blip.type = "sine"
    blip.frequency.setValueAtTime(randomBetween(700, 1000), startedAt)
    blip.frequency.exponentialRampToValueAtTime(140, startedAt + POP_SOUND_SECONDS)
    blip.connect(volume)
    blip.start(startedAt)
    blip.stop(startedAt + POP_SOUND_SECONDS)
  }

  closeAudio() {
    this.audio?.close()
    // Stimulus reuses the instance when the element is re-inserted, and a closed
    // context throws on every node it is asked for - so forget it, don't reuse it.
    this.audio = undefined
  }

  audioContext() {
    if (this.audio === undefined) {
      const Context = window.AudioContext || window.webkitAudioContext
      this.audio = Context ? new Context() : null
    }

    // Browsers hand out a suspended context until a gesture arrives - and a pop is one.
    if (this.audio?.state === "suspended") this.audio.resume()

    return this.audio
  }

  noiseBuffer(audio) {
    if (!this.noise) {
      const samples = Math.floor(audio.sampleRate * POP_SOUND_SECONDS)
      this.noise = audio.createBuffer(1, samples, audio.sampleRate)
      const channel = this.noise.getChannelData(0)

      for (let i = 0; i < samples; i++) {
        channel[i] = (Math.random() * 2 - 1) * (1 - i / samples)
      }
    }

    return this.noise
  }

  spawn() {
    if (document.hidden || !this.hasArenaTarget) return
    if (this.arenaTarget.childElementCount >= MAX_BALLOONS) return

    this.arenaTarget.appendChild(this.buildBalloon())
  }

  buildBalloon() {
    const balloon = document.createElement("button")
    balloon.type = "button"
    balloon.className = "balloon"
    balloon.setAttribute("aria-label", this.popLabelValue)
    balloon.style.setProperty("--balloon-left", `${randomBetween(4, 88)}%`)
    balloon.style.setProperty("--balloon-size", `${randomBetween(40, 68)}px`)
    balloon.style.setProperty("--balloon-drift", `${randomBetween(-40, 40)}px`)
    balloon.style.setProperty("--balloon-duration", `${randomBetween(6, 11)}s`)
    balloon.style.setProperty("--balloon-color", COLORS[Math.floor(Math.random() * COLORS.length)])
    balloon.innerHTML = '<span class="balloon__body"></span><span class="balloon__string"></span>'
    balloon.addEventListener("animationend", () => balloon.remove())

    return balloon
  }

  flush() {
    if (this.pendingPops < 1) return

    // Never post more than the server accepts in one go - the rest rides along on
    // the next flush instead of being clamped away silently.
    const count = Math.min(this.pendingPops, this.maxBatchValue)
    this.pendingPops -= count

    fetch(this.urlValue, {
      method: "POST",
      keepalive: true,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: JSON.stringify({ count })
    }).then(response => {
      // A redirect means the session expired and the POST landed on the login page.
      if (!response.ok || response.redirected) this.retry(count)
    }).catch(() => this.retry(count))
  }

  retry(count) {
    this.pendingPops += count
  }
}

function randomBetween(min, max) {
  return Math.round(min + Math.random() * (max - min))
}

import { vi, describe, it, expect, beforeEach, afterEach } from "vitest"

import { Application } from "@hotwired/stimulus"
import BalloonGameController from "../../app/javascript/controllers/balloon_game_controller"

describe("balloon-game controller", () => {
  let application

  function buildGame() {
    document.body.innerHTML = `
      <meta name="csrf-token" content="token">
      <div id="game"
           data-controller="balloon-game"
           data-balloon-game-url-value="/1/retros/1/balloon_pops"
           data-balloon-game-score-value="7"
           data-balloon-game-pop-label-value="Pop balloon"
           data-balloon-game-max-batch-value="50">
        <span data-balloon-game-target="score">7</span>
        <div data-balloon-game-target="arena"
             data-action="pointerdown->balloon-game#pop click->balloon-game#pop"></div>
      </div>
    `
  }

  function arena() {
    return document.querySelector("[data-balloon-game-target='arena']")
  }

  function score() {
    return document.querySelector("[data-balloon-game-target='score']")
  }

  async function startedController() {
    await Promise.resolve()
    return application.getControllerForElementAndIdentifier(document.getElementById("game"), "balloon-game")
  }

  async function balloon() {
    const controller = await startedController()
    controller.spawn()
    return arena().lastElementChild
  }

  // The fetch chain settles over several microtasks, so let them all drain.
  async function settled() {
    for (let i = 0; i < 3; i++) await Promise.resolve()
  }

  function popEvent(element) {
    return new MouseEvent("pointerdown", { bubbles: true, target: element })
  }

  // Stands in for the Web Audio API, which happy-dom does not implement, and records
  // the nodes the controller wires up for a pop.
  function fakeAudioContext() {
    const started = []
    const node = () => ({ connect: vi.fn(function (target) { return target }) })
    const context = {
      state: "suspended",
      currentTime: 0,
      sampleRate: 44100,
      resume: vi.fn(function () { context.state = "running" }),
      close: vi.fn(),
      destination: node(),
      createGain: vi.fn(() => ({
        ...node(),
        gain: { setValueAtTime: vi.fn(), exponentialRampToValueAtTime: vi.fn() }
      })),
      createBiquadFilter: vi.fn(() => ({ ...node(), type: "", frequency: {} })),
      createBuffer: vi.fn((channels, samples) => ({ getChannelData: () => new Float32Array(samples) })),
      createBufferSource: vi.fn(() => ({ ...node(), buffer: null, start: vi.fn(() => started.push("noise")) })),
      createOscillator: vi.fn(() => ({
        ...node(),
        type: "",
        frequency: { setValueAtTime: vi.fn(), exponentialRampToValueAtTime: vi.fn() },
        start: vi.fn(() => started.push("blip")),
        stop: vi.fn()
      })),
      started
    }
    return context
  }

  beforeEach(async () => {
    vi.useFakeTimers()
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true, redirected: false }))
    buildGame()
    application = Application.start()
    application.register("balloon-game", BalloonGameController)
  })

  afterEach(() => {
    application.stop()
    vi.restoreAllMocks()
    vi.unstubAllGlobals()
    vi.useRealTimers()
    document.body.innerHTML = ""
  })

  it("spawns balloons into the arena", async () => {
    const controller = await startedController()
    controller.spawn()
    controller.spawn()

    expect(arena().querySelectorAll(".balloon").length).toBeGreaterThanOrEqual(2)
    expect(arena().querySelector(".balloon").getAttribute("aria-label")).toBe("Pop balloon")
  })

  it("stops spawning once the arena is full", async () => {
    const controller = await startedController()

    for (let i = 0; i < 40; i++) controller.spawn()

    expect(arena().childElementCount).toBe(14)
  })

  it("counts a pop and marks the balloon as popped", async () => {
    const controller = await startedController()
    const target = await balloon()

    target.dispatchEvent(popEvent(target))

    expect(target.hasAttribute("data-popped")).toBe(true)
    expect(controller.pendingPops).toBe(1)
    expect(score().textContent).toBe("8")
  })

  it("counts a balloon once even though pointerdown is followed by a click", async () => {
    const controller = await startedController()
    const target = await balloon()

    target.dispatchEvent(popEvent(target))
    target.dispatchEvent(new MouseEvent("click", { bubbles: true }))

    expect(controller.pendingPops).toBe(1)
    expect(score().textContent).toBe("8")
  })

  it("removes a popped balloon after the burst animation", async () => {
    const target = await balloon()

    target.dispatchEvent(popEvent(target))
    vi.advanceTimersByTime(300)

    expect(target.isConnected).toBe(false)
  })

  it("posts the pops collected since the last flush as one batch", async () => {
    const controller = await startedController()
    const first = await balloon()
    const second = await balloon()
    first.dispatchEvent(popEvent(first))
    second.dispatchEvent(popEvent(second))

    controller.flush()

    expect(fetch).toHaveBeenCalledWith("/1/retros/1/balloon_pops", expect.objectContaining({
      method: "POST",
      body: JSON.stringify({ count: 2 })
    }))
    expect(controller.pendingPops).toBe(0)
  })

  it("does not post anything when no balloon was popped", async () => {
    const controller = await startedController()

    controller.flush()

    expect(fetch).not.toHaveBeenCalled()
  })

  it("plays a pop sound on the first click and reuses the audio context after that", async () => {
    const context = fakeAudioContext()
    vi.stubGlobal("AudioContext", vi.fn(() => context))
    const controller = await startedController()
    const first = await balloon()
    const second = await balloon()

    first.dispatchEvent(popEvent(first))
    second.dispatchEvent(popEvent(second))

    expect(AudioContext).toHaveBeenCalledTimes(1)
    expect(context.resume).toHaveBeenCalled()
    expect(context.started).toEqual(["noise", "blip", "noise", "blip"])
    expect(context.createBuffer).toHaveBeenCalledTimes(1)
  })

  it("pops silently when the browser has no Web Audio support", async () => {
    vi.stubGlobal("AudioContext", undefined)
    vi.stubGlobal("webkitAudioContext", undefined)
    const controller = await startedController()
    const target = await balloon()

    target.dispatchEvent(popEvent(target))

    expect(controller.pendingPops).toBe(1)
  })

  it("never posts a bigger batch than the server accepts and keeps the rest", async () => {
    const controller = await startedController()
    controller.pendingPops = 63

    controller.flush()

    expect(fetch).toHaveBeenCalledWith("/1/retros/1/balloon_pops", expect.objectContaining({
      body: JSON.stringify({ count: 50 })
    }))
    expect(controller.pendingPops).toBe(13)
  })

  it("keeps the pops when the server rejects the batch", async () => {
    const controller = await startedController()
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false, redirected: false }))
    const target = await balloon()
    target.dispatchEvent(popEvent(target))

    controller.flush()
    await settled()

    expect(controller.pendingPops).toBe(1)
  })

  it("keeps the pops when an expired session redirects the post to the login page", async () => {
    const controller = await startedController()
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true, redirected: true }))
    const target = await balloon()
    target.dispatchEvent(popEvent(target))

    controller.flush()
    await settled()

    expect(controller.pendingPops).toBe(1)
  })

  it("builds a fresh audio context after a disconnect closed the old one", async () => {
    const contexts = [ fakeAudioContext(), fakeAudioContext() ]
    vi.stubGlobal("AudioContext", vi.fn(() => contexts.shift()))
    const controller = await startedController()
    const target = await balloon()
    target.dispatchEvent(popEvent(target))

    controller.disconnect()
    controller.connect()
    const next = await balloon()
    next.dispatchEvent(popEvent(next))

    expect(AudioContext).toHaveBeenCalledTimes(2)
  })

  it("keeps the pops for the next flush when the request fails", async () => {
    const controller = await startedController()
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("network down")))
    const target = await balloon()
    target.dispatchEvent(popEvent(target))

    controller.flush()
    await settled()

    expect(controller.pendingPops).toBe(1)
  })
})

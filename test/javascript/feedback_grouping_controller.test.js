import { vi, describe, it, expect, beforeEach, afterEach } from "vitest"

vi.mock("sortablejs", () => ({
  default: { create: vi.fn(() => ({ destroy: vi.fn() })) }
}))

import { Application } from "@hotwired/stimulus"
import FeedbackGroupingController from "../../app/javascript/controllers/feedback_grouping_controller"

describe("feedback-grouping controller", () => {
  let application

  function buildColumns() {
    document.body.innerHTML = `
      <div data-feedback-column>
        <div id="feedback-list-could_be_better"
             data-controller="feedback-grouping"
             data-feedback-grouping-move-url-value="/1/retros/1/feedbacks/__id__/category"
             data-feedback-grouping-group-url-value="/1/retros/1/feedback_groups"
             data-feedback-grouping-group-name-value="retro-1-feedback-columns"
             data-feedback-grouping-grouping-enabled-value="true"
             data-feedback-grouping-target="list"
             data-feedback-category="could_be_better">
          <div id="feedback_1" data-feedback-id="1" data-feedback-grouping-target="feedback"></div>
        </div>
      </div>
      <div data-feedback-column>
        <div id="feedback-list-went_well"
             data-controller="feedback-grouping"
             data-feedback-grouping-move-url-value="/1/retros/1/feedbacks/__id__/category"
             data-feedback-grouping-group-url-value="/1/retros/1/feedback_groups"
             data-feedback-grouping-group-name-value="retro-1-feedback-columns"
             data-feedback-grouping-grouping-enabled-value="true"
             data-feedback-grouping-target="list"
             data-feedback-category="went_well">
        </div>
      </div>
    `
  }

  function sourceList() {
    return document.getElementById("feedback-list-could_be_better")
  }

  function targetList() {
    return document.getElementById("feedback-list-went_well")
  }

  function item() {
    return document.getElementById("feedback_1")
  }

  async function controllerFor(element) {
    await Promise.resolve()
    return application.getControllerForElementAndIdentifier(element, "feedback-grouping")
  }

  // Simulates the state right after Sortable finished a cross-column drop:
  // the card is already in the target list, the controller remembers its origin.
  async function controllerAfterDrop() {
    const controller = await controllerFor(sourceList())
    controller.sourceList = sourceList()
    controller.sourceNextSibling = null
    targetList().append(item())
    return controller
  }

  beforeEach(async () => {
    buildColumns()
    application = Application.start()
    application.register("feedback-grouping", FeedbackGroupingController)
  })

  afterEach(() => {
    application.stop()
    vi.restoreAllMocks()
    vi.useRealTimers()
    document.body.innerHTML = ""
  })

  it("sends a PATCH with the target category on success and shows no error", async () => {
    const controller = await controllerAfterDrop()
    const fetchMock = vi.fn().mockResolvedValue({ ok: true, redirected: false })
    vi.stubGlobal("fetch", fetchMock)

    await controller.moveFeedback(item(), targetList())

    expect(fetchMock).toHaveBeenCalledWith("/1/retros/1/feedbacks/1/category", expect.objectContaining({
      method: "PATCH",
      body: JSON.stringify({ category: "went_well" })
    }))
    expect(targetList().contains(item())).toBe(true)
    expect(document.getElementById("feedback-move-error")).toBeNull()
  })

  it("restores the card and shows an error banner when the server rejects the move", async () => {
    const controller = await controllerAfterDrop()
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false, redirected: false }))
    vi.spyOn(console, "error").mockImplementation(() => {})

    await controller.moveFeedback(item(), targetList())

    expect(sourceList().contains(item())).toBe(true)
    expect(document.getElementById("feedback-move-error")).not.toBeNull()
  })

  it("treats a followed redirect (expired session) as a failure", async () => {
    const controller = await controllerAfterDrop()
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true, redirected: true }))
    vi.spyOn(console, "error").mockImplementation(() => {})

    await controller.moveFeedback(item(), targetList())

    expect(sourceList().contains(item())).toBe(true)
    expect(document.getElementById("feedback-move-error")).not.toBeNull()
  })

  it("restores the card and shows an error banner when the request throws", async () => {
    const controller = await controllerAfterDrop()
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("network down")))
    vi.spyOn(console, "error").mockImplementation(() => {})

    await controller.moveFeedback(item(), targetList())

    expect(sourceList().contains(item())).toBe(true)
    expect(document.getElementById("feedback-move-error")).not.toBeNull()
  })

  it("does not resurrect a card that a broadcast already removed from the DOM", async () => {
    const controller = await controllerAfterDrop()
    const card = item()
    card.remove()

    controller.restoreDraggedItem(card)

    expect(card.isConnected).toBe(false)
  })

  it("restores into the live list when the remembered source list was replaced by a morph", async () => {
    const controller = await controllerAfterDrop()
    const staleList = sourceList()
    const freshList = staleList.cloneNode(false)
    staleList.replaceWith(freshList)
    controller.sourceList = staleList

    controller.restoreDraggedItem(item())

    expect(freshList.contains(item())).toBe(true)
  })

  it("reinserts before the remembered next sibling when it is still in place", async () => {
    const controller = await controllerFor(sourceList())
    const sibling = document.createElement("div")
    sibling.id = "feedback_2"
    sourceList().append(sibling)
    controller.sourceList = sourceList()
    controller.sourceNextSibling = sibling
    targetList().append(item())

    controller.restoreDraggedItem(item())

    expect(item().nextElementSibling).toBe(sibling)
  })

  it("shows a single error banner that removes itself after four seconds", async () => {
    vi.useFakeTimers()
    const controller = await controllerFor(sourceList())

    controller.showMoveError()
    controller.showMoveError()

    expect(document.querySelectorAll("#feedback-move-error").length).toBe(1)

    vi.advanceTimersByTime(4000)
    expect(document.getElementById("feedback-move-error")).toBeNull()
  })
})

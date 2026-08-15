require "application_system_test_case"

class BalloonGameTest < ApplicationSystemTestCase
  test "popping balloons scores the participant on the highscore" do
    retro = retros(:one)
    retro.update!(phase: :complete)
    sign_in_as users(:one)

    visit retro_complete_path(retro)

    assert_selector ".balloon-arena .balloon"
    freeze_balloons_mid_flight
    3.times { find(".balloon-arena .balloon:not([data-popped])", match: :first).click }

    assert_selector "[data-balloon-game-target='score']", text: "3"
    within "#balloon-leaderboard" do
      assert_selector "li", text: users(:one).name
      assert_selector "li", text: "3"
    end
    assert_equal 3, retro.participants.find_by(user: users(:one)).balloons_popped
    # The broadcast replaces only the highscore, so the panel keeps its arena and board.
    assert_equal 2, page.evaluate_script("document.querySelector(\"[data-controller='balloon-game']\").children.length")
    # Stimulus swallows errors thrown inside an action into console.error, so a broken
    # pop - Web Audio included - surfaces here rather than as a failed assertion above.
    assert_empty browser_errors
  end

  private
    # Balloons drift upward and remove themselves when the float ends, which makes a
    # click race the animation. Parking them mid-flight keeps the click real without
    # chasing a moving target.
    def freeze_balloons_mid_flight
      page.execute_script(<<~JS)
        document.head.insertAdjacentHTML("beforeend",
          "<style>.balloon { animation-delay: -3s !important; animation-play-state: paused !important; }</style>")
      JS
    end

    def browser_errors
      page.driver.browser.logs.get(:browser).select { |log| log.level == "SEVERE" }
    end

    def sign_in_as(user)
      visit session_transfer_url(user.identity.transfer_id, script_name: nil)
      assert_selector "h1", text: "YOUR RETROS"
    end
end

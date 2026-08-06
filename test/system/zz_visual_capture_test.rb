require "application_system_test_case"

# Throwaway capture harness used during the redesign to eyeball screens.
# Delete before merging.
class ZzVisualCaptureTest < ApplicationSystemTestCase
  SHOTS = "/tmp/claude-1000/-home-hobbit-Desktop-personal-faster-fastretro/58398ecf-0694-40ed-87c8-cf800f1003e7/scratchpad/shots".freeze

  test "capture signed out screens" do
    FileUtils.mkdir_p(SHOTS)

    visit root_path
    shoot "01-landing"

    visit new_session_path(script_name: nil)
    assert_selector "input[type=email]", wait: 5
    shoot "02-signin"
  end

  test "capture signed in screens" do
    FileUtils.mkdir_p(SHOTS)
    visit session_transfer_url(users(:one).identity.transfer_id, script_name: nil)
    assert_selector "h1", text: "YOUR RETROS"
    shoot "03-dashboard"

    retro = retros(:one)
    retro.update!(phase: :grouping)
    visit retro_grouping_path(retro)
    shoot "04-board-grouping"

    retro.update!(phase: :brainstorming)
    visit retro_brainstorming_path(retro)
    shoot "05-board-brainstorming"
  end

  private
    def shoot(name)
      sleep 0.6
      page.save_screenshot("#{SHOTS}/#{name}.png")
    rescue StandardError => e
      puts "SHOT FAILED #{name}: #{e.class}: #{e.message}"
    end
end

require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "signing in and creating a retro" do
    sign_in_as users(:one)

    visit retros_path
    click_on "NEW RETRO"
    fill_in "retro_name", with: "System Test Retro"
    assert_field "retro_name", with: "System Test Retro"
    within "form#retro-form" do
      click_button "CREATE_RETRO"
    end

    assert_current_path %r{\A/1000001/retros/\d+/waiting_room\z}, ignore_query: true
    assert_selector "h1", text: /SYSTEM TEST RETRO/i
    assert_selector "button", text: "START RETRO"
  end

  test "starting a retro and moving to grouping" do
    sign_in_as users(:one)

    retro = retros(:one)
    visit retro_waiting_room_path(retro)
    click_on "START RETRO"

    assert_current_path retro_brainstorming_path(retro), ignore_query: true

    click_on "Complete Phase"
    click_on "Yes, Continue"

    assert_current_path retro_grouping_path(retro), ignore_query: true
    assert_selector "#retro-column-went_well"
  end

  private
    def sign_in_as(user)
      visit session_transfer_url(user.identity.transfer_id, script_name: nil)
      assert_selector "h1", text: "YOUR RETROS"
    end
end

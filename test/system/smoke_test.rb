require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "signing in and creating a retro" do
    sign_in_as users(:one)

    visit retros_path
    find("#new-retro-button").click
    fill_in "retro_name", with: "System Test Retro"
    assert_field "retro_name", with: "System Test Retro"
    within "form#retro-form" do
      find("#retro-submit-button").click
    end

    assert_current_path %r{\A/1000001/retros/\d+/waiting_room\z}, ignore_query: true
    assert_selector "h1", text: /SYSTEM TEST RETRO/i
    assert_selector "#start-retro-button"
  end

  test "starting a retro and moving to grouping" do
    sign_in_as users(:one)

    retro = retros(:one)
    visit retro_waiting_room_path(retro)
    find("#start-retro-button").click

    assert_current_path retro_brainstorming_path(retro), ignore_query: true

    advance_phase_from_modal

    assert_current_path retro_grouping_path(retro), ignore_query: true
    assert_selector "#retro-column-went_well"
  end

  test "full realtime collaboration flow across all phases" do
    retro = accounts(:one).retros.create!(name: "Realtime Full Flow Retro")
    retro.add_participant(users(:one), role: :admin)
    retro.add_participant(users(:two), role: :participant)
    retro.update!(phase: :brainstorming)

    admin_participant = retro.participants.find_by!(user: users(:one))
    member_participant = retro.participants.find_by!(user: users(:two))

    admin_feedbacks = [ "Admin point 1", "Admin point 2", "Admin point 3" ]
    participant_feedbacks = [ "Participant point 1", "Participant point 2", "Participant point 3" ]
    all_feedbacks = admin_feedbacks + participant_feedbacks
    grouped_badge = "2 GROUPED"
    action_items = [ "Write release note", "Create follow-up ticket" ]

    # Brainstorming: both participants add feedback (total: 6).
    using_session(:admin) do
      sign_in_as users(:one)
      visit retro_brainstorming_path(retro)
      assert_current_path retro_brainstorming_path(retro), ignore_query: true
      admin_feedbacks.each { |content| create_feedback(retro:, category: "went_well", content:) }
    end

    using_session(:participant) do
      sign_in_as users(:two)
      visit retro_brainstorming_path(retro)
      assert_current_path retro_brainstorming_path(retro), ignore_query: true
      participant_feedbacks.each { |content| create_feedback(retro:, category: "went_well", content:) }

      # Participant marks themselves finished; admin should see this status update.
      find("#participant-finished-button").click
      assert_selector "#participant-finished-button", text: /finished/i
    end

    using_session(:admin) do
      within "#participant-list" do
        assert_text "TEST USER TWO"
        assert_text "MEMBER // FINISHED"
      end
    end

    # Brainstorming -> Grouping: admin advances, participant is auto-redirected.
    using_session(:admin) do
      advance_phase_from_modal
      assert_current_path retro_grouping_path(retro), ignore_query: true
      assert_all_feedbacks_present(all_feedbacks)
    end

    using_session(:participant) do
      assert_current_path retro_grouping_path(retro), ignore_query: true
      assert_all_feedbacks_present(all_feedbacks)
    end

    # Grouping: admin groups two cards; participant sees it in realtime.
    using_session(:admin) do
      group_feedbacks(source_text: participant_feedbacks.first, target_text: admin_feedbacks.first)
      assert_selector "[id^='feedback_group_']"
      assert_text grouped_badge
    end

    using_session(:participant) do
      assert_selector "[id^='feedback_group_']"
      assert_text grouped_badge
    end

    # Grouping: ungroup again and verify realtime sync to participant.
    using_session(:admin) do
      find("[id^='ungroup-all-feedback-group-']", match: :first).click
      assert_no_selector "[id^='feedback_group_']"
    end

    using_session(:participant) do
      assert_no_selector "[id^='feedback_group_']"
    end

    # Group once more so we can validate vote sorting for grouped items.
    using_session(:admin) do
      group_feedbacks(source_text: participant_feedbacks.first, target_text: admin_feedbacks.first)
      assert_selector "[id^='feedback_group_']"
      assert_text grouped_badge
    end

    # Grouping -> Voting: admin advances, participant is auto-redirected.
    using_session(:admin) do
      advance_phase_from_modal
      assert_current_path retro_voting_path(retro), ignore_query: true
      assert_votes_remaining(participant_id: admin_participant.id, count: 3)
    end

    using_session(:participant) do
      assert_current_path retro_voting_path(retro), ignore_query: true
      assert_votes_remaining(participant_id: member_participant.id, count: 3)
    end

    # Voting realtime: vote counts update for both users and remaining votes decrease.
    using_session(:admin) do
      add_vote_to_item(item_text: admin_feedbacks.last)
      assert_vote_total(item_text: admin_feedbacks.last, total: 1)
      assert_votes_remaining(participant_id: admin_participant.id, count: 2)

      add_vote_to_item(item_text: grouped_badge)
      assert_vote_total(item_text: grouped_badge, total: 1)
      assert_votes_remaining(participant_id: admin_participant.id, count: 1)
    end

    using_session(:participant) do
      assert_vote_total(item_text: admin_feedbacks.last, total: 1)
      assert_vote_total(item_text: grouped_badge, total: 1)

      add_vote_to_item(item_text: grouped_badge)
      assert_vote_total(item_text: grouped_badge, total: 2)
      assert_votes_remaining(participant_id: member_participant.id, count: 2)

      # Highest-voted item should float to the top.
      assert_top_votable_contains(category: "went_well", text: grouped_badge)
    end

    using_session(:admin) do
      assert_vote_total(item_text: grouped_badge, total: 2)
      assert_top_votable_contains(category: "went_well", text: grouped_badge)
    end

    # Voting -> Discussion: admin advances, participant is auto-redirected.
    using_session(:admin) do
      advance_phase_from_modal
      assert_current_path retro_discussion_path(retro), ignore_query: true
    end

    using_session(:participant) do
      assert_current_path retro_discussion_path(retro), ignore_query: true
    end

    # Discussion realtime: moderator creates actions and participant sees them live.
    using_session(:admin) do
      action_items.each { |content| create_action(retro:, content:) }
    end

    using_session(:participant) do
      action_items.each { |content| assert_text content }
    end

    # Discussion -> Complete: admin advances, participant is auto-redirected.
    using_session(:admin) do
      advance_phase_from_modal
      assert_current_path retro_complete_path(retro), ignore_query: true
      action_items.each { |content| assert_text content }
      assert_selector "#export-xlsx-button"
      assert_selector "#export-csv-button"
      assert_selector "#export-xlsx-button[href='#{retro_export_path(retro, format: :xlsx)}']"
      assert_selector "#export-csv-button[href='#{retro_export_path(retro, format: :csv)}']"
    end

    using_session(:participant) do
      assert_current_path retro_complete_path(retro), ignore_query: true
      action_items.each { |content| assert_text content }
      assert_selector "#export-xlsx-button"
      assert_selector "#export-csv-button"
      assert_selector "#export-xlsx-button[href='#{retro_export_path(retro, format: :xlsx)}']"
      assert_selector "#export-csv-button[href='#{retro_export_path(retro, format: :csv)}']"
    end
  end

  private
    def sign_in_as(user)
      visit session_transfer_url(user.identity.transfer_id, script_name: nil)
      assert_selector "h1", text: "YOUR RETROS"
    end

    def create_feedback(retro:, category:, content:)
      within "#retro-column-#{category}" do
        find("#add-feedback-button-#{category}").click
      end

      fill_in_lexxy with: content
      find("#create-feedback-button").click

      assert_current_path retro_brainstorming_path(retro), ignore_query: true
      assert_text content
    end

    def create_action(retro:, content:)
      within "#actions-column" do
        find("#add-action-button").click
      end

      fill_in_lexxy with: content
      find("#create-action-button").click

      assert_current_path retro_discussion_path(retro), ignore_query: true
      assert_text content
    end

    def advance_phase_from_modal
      find("#complete-phase-button").click
      find("#confirm-phase-continue-button").click
    end

    def group_feedbacks(source_text:, target_text:)
      source = find("[id^='feedback_']", text: source_text, match: :first)
      target = find("[id^='feedback_']", text: target_text, match: :first)
      source.drag_to(target)
    end

    def add_vote_to_item(item_text:)
      within find("[data-vote-sorting-target='item']", text: item_text, match: :first) do
        find("[id^='add-vote-button-']", match: :first).click
      end
    end

    def assert_vote_total(item_text:, total:)
      within find("[data-vote-sorting-target='item']", text: item_text, match: :first) do
        assert_selector "[data-vote-total]", text: total.to_s, wait: 5
      end
    end

    def assert_votes_remaining(participant_id:, count:)
      assert_selector "#votes_remaining_#{participant_id} > span:last-child", text: count.to_s
    end

    def assert_top_votable_contains(category:, text:)
      assert_selector "#feedback-list-#{category} > [data-vote-sorting-target='item']:first-child", text: text
    end

    def assert_all_feedbacks_present(feedbacks)
      feedbacks.each { |feedback| assert_text feedback }
    end

    def fill_in_lexxy(selector = "lexxy-editor", with:)
      editor = find(selector)
      editor.set with
      page.execute_script("arguments[0].value = arguments[1]", editor, with)
    end
end

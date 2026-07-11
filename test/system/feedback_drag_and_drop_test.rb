require "application_system_test_case"

class FeedbackDragAndDropTest < ApplicationSystemTestCase
  test "admin moves feedback between columns during grouping" do
    retro = retros(:one)
    feedback = feedbacks(:one)
    retro.update!(phase: :grouping)
    sign_in_as users(:one)

    visit retro_grouping_path(retro)

    source = find("#feedback_#{feedback.id}")
    target = find("#feedback-list-could_be_better")
    source.drag_to(target)

    assert_selector "#feedback-list-could_be_better #feedback_#{feedback.id}"
    assert_equal "could_be_better", feedback.reload.category
  end

  test "participant moves their own feedback between columns during brainstorming" do
    retro = retros(:one)
    feedback = feedbacks(:two)
    retro.update!(phase: :brainstorming)
    sign_in_as users(:two)

    visit retro_brainstorming_path(retro)

    source = find("#feedback_#{feedback.id}")
    target = find("#feedback-list-went_well")
    source.drag_to(target)

    assert_selector "#feedback-list-went_well #feedback_#{feedback.id}"
    assert_equal "went_well", feedback.reload.category
  end

  test "admin still groups feedback within a column" do
    retro = retros(:one)
    source_feedback = feedbacks(:one)
    target_feedback = Feedback.create!(
      retro: retro,
      user: users(:two),
      category: :went_well,
      status: :published
    )
    retro.update!(phase: :grouping)
    sign_in_as users(:one)

    visit retro_grouping_path(retro)

    source = find("#feedback_#{source_feedback.id}")
    target = find("#feedback_#{target_feedback.id}")
    source.drag_to(target)

    assert_selector "[data-feedback-id^='group-']"
    assert_equal target_feedback.reload.feedback_group_id, source_feedback.reload.feedback_group_id
    assert_not_nil source_feedback.feedback_group_id
  end

  private
    def sign_in_as(user)
      visit session_transfer_url(user.identity.transfer_id, script_name: nil)
      assert_selector "h1", text: "YOUR RETROS"
    end
end

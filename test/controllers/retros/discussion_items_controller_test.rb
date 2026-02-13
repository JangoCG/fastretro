require "test_helper"

class Retros::DiscussionItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @retro.update!(phase: :discussion)

    @admin_user = users(:one)
    @member_user = users(:two)
    @retro.add_participant(@member_user, role: :participant)

    @feedback = feedbacks(:one)
    @feedback_group = @retro.feedback_groups.create!
    @feedback.update!(feedback_group: @feedback_group)
  end

  test "admin can mark feedback as discussed" do
    sign_in_as :one

    patch retro_discussion_item_path(@retro),
      params: {
        item_type: "Feedback",
        item_id: @feedback.id,
        discussed: true
      },
      as: :turbo_stream

    assert_response :success
    assert @feedback.reload.discussed?
  end

  test "admin can mark feedback group as discussed" do
    sign_in_as :one

    patch retro_discussion_item_path(@retro),
      params: {
        item_type: "FeedbackGroup",
        item_id: @feedback_group.id,
        discussed: true
      },
      as: :turbo_stream

    assert_response :success
    assert @feedback_group.reload.discussed?
  end

  test "non admin cannot mark discussion items" do
    sign_in_as :two

    patch retro_discussion_item_path(@retro),
      params: {
        item_type: "Feedback",
        item_id: @feedback.id,
        discussed: true
      },
      as: :turbo_stream

    assert_redirected_to retros_path
    assert_not @feedback.reload.discussed?
  end

  test "cannot mark items outside discussion phase" do
    sign_in_as :one
    @retro.update!(phase: :voting)

    patch retro_discussion_item_path(@retro),
      params: {
        item_type: "Feedback",
        item_id: @feedback.id,
        discussed: true
      },
      as: :turbo_stream

    assert_redirected_to retro_path(@retro)
    assert_not @feedback.reload.discussed?
  end
end

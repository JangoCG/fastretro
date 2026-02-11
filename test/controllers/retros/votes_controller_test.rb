require "test_helper"

class Retros::VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @retro.update!(phase: :voting)

    @admin_user = users(:one)
    @member_user = users(:two)
    @retro.add_participant(@member_user, role: :participant)

    @feedback = feedbacks(:one)
  end

  test "create broadcasts vote total update to retro stream" do
    sign_in_as :one

    calls = []
    Turbo::StreamsChannel.stubs(:broadcast_update_to).with do |stream, options|
      calls << [ stream, options[:target], options[:html] ]
      true
    end

    post retro_votes_path(@retro),
      params: {
        voteable_type: "Feedback",
        voteable_id: @feedback.id
      },
      as: :turbo_stream

    assert_response :success

    expected_calls = [
      [ @retro, "vote_total_feedback_#{@feedback.id}", "1" ]
    ]

    assert_equal expected_calls, calls
  end

  test "create enforces retro-specific vote limit" do
    sign_in_as :one
    @retro.configure_column_layout(layout_mode: "custom", column_names: [ "Went well" ], votes_per_participant: 1)
    @retro.save!

    assert_difference("Vote.count", 1) do
      post retro_votes_path(@retro),
        params: { voteable_type: "Feedback", voteable_id: @feedback.id },
        as: :turbo_stream
    end
    assert_response :success

    assert_no_difference("Vote.count") do
      post retro_votes_path(@retro),
        params: { voteable_type: "Feedback", voteable_id: @feedback.id },
        as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end
end

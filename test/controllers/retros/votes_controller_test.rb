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

  test "create broadcasts updated vote button to all participant streams" do
    sign_in_as :one

    calls = []
    Turbo::StreamsChannel.stubs(:broadcast_replace_to).with do |stream, options|
      calls << [ stream, options[:target], options[:partial] ]
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
      [ [ @retro, @admin_user ], "vote_button_feedback_#{@feedback.id}", "retros/votes/vote_button" ],
      [ [ @retro, @member_user ], "vote_button_feedback_#{@feedback.id}", "retros/votes/vote_button" ]
    ]

    assert_equal expected_calls.sort_by(&:to_s), calls.sort_by(&:to_s)
  end
end

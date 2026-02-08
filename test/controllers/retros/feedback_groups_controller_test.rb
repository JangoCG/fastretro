require "test_helper"

class Retros::FeedbackGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @admin_user = users(:one)
    @member_user = users(:two)
    @retro.add_participant(@member_user, role: :participant)
    @retro.update!(phase: :grouping)

    @source_feedback = Feedback.create!(
      retro: @retro,
      user: @admin_user,
      category: :went_well,
      status: :published
    )
    @target_feedback = Feedback.create!(
      retro: @retro,
      user: @member_user,
      category: :went_well,
      status: :published
    )
  end

  test "create broadcasts final grouped columns once per participant and category" do
    sign_in_as :one

    calls = []
    Turbo::StreamsChannel.stubs(:broadcast_replace_to).with do |stream, options|
      calls << [ stream, options[:target], options[:partial] ]
      true
    end

    post retro_feedback_groups_path(@retro),
      params: {
        source_feedback_id: @source_feedback.id,
        target_feedback_id: @target_feedback.id
      },
      as: :turbo_stream

    assert_response :success

    expected_calls = [
      [ [ @retro, @admin_user ], "retro-column-went_well", "retros/streams/column" ],
      [ [ @retro, @admin_user ], "retro-column-could_be_better", "retros/streams/column" ],
      [ [ @retro, @member_user ], "retro-column-went_well", "retros/streams/column" ],
      [ [ @retro, @member_user ], "retro-column-could_be_better", "retros/streams/column" ]
    ]

    assert_equal expected_calls.sort_by(&:to_s), calls.sort_by(&:to_s)
  end
end

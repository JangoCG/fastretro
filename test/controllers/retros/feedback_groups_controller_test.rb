require "test_helper"

class Retros::FeedbackGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @admin_user = users(:one)
    @member_user = users(:two)
    @second_member_user = User.create!(
      account: @retro.account,
      identity: identities(:staff),
      name: "Second Member",
      role: :member,
      active: true,
      verified_at: Time.current
    )
    @retro.add_participant(@member_user, role: :participant)
    @retro.add_participant(@second_member_user, role: :participant)
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
    rendered_columns = []

    ApplicationController.stubs(:render).with do |options|
      rendered_columns << [ options[:locals][:participant].admin?, options[:locals][:category] ]
      true
    end.returns("<div>column</div>")

    Turbo::StreamsChannel.stubs(:broadcast_replace_to).with do |stream, options|
      calls << [ stream, options[:target], options[:html].present? ]
      true
    end

    post retro_feedback_groups_path(@retro),
      params: {
        source_feedback_id: @source_feedback.id,
        target_feedback_id: @target_feedback.id
      },
      as: :turbo_stream

    assert_response :success

    expected_calls = @retro.column_categories.flat_map do |category|
      [
        [ [ @retro, @admin_user ], "retro-column-#{category}", true ],
        [ [ @retro, @member_user ], "retro-column-#{category}", true ],
        [ [ @retro, @second_member_user ], "retro-column-#{category}", true ]
      ]
    end

    assert_equal expected_calls.sort_by(&:to_s), calls.sort_by(&:to_s)

    expected_rendered_columns = @retro.column_categories.flat_map do |category|
      [ [ true, category ], [ false, category ] ]
    end

    assert_equal expected_rendered_columns.sort_by(&:to_s), rendered_columns.sort_by(&:to_s)
  end
end

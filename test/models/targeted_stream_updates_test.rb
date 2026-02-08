require "test_helper"

class TargetedStreamUpdatesTest < ActiveSupport::TestCase
  setup do
    @retro = retros(:one)
    @user = users(:one)
    Current.user = @user
  end

  test "feedback broadcasts targeted column replacements when published" do
    expect_column_replacements

    Feedback.create!(
      retro: @retro,
      user: @user,
      category: :went_well,
      status: :published
    )
  end

  test "feedback does not broadcast column replacements when drafted" do
    Turbo::StreamsChannel.expects(:broadcast_replace_to).never

    Feedback.create!(
      retro: @retro,
      user: @user,
      category: :went_well,
      status: :drafted
    )
  end

  test "feedback group broadcasts targeted column replacements" do
    expect_column_replacements

    @retro.feedback_groups.create!
  end

  test "participant updates waiting room participants section in waiting room phase" do
    @retro.update!(phase: :waiting_room)

    Turbo::StreamsChannel.expects(:broadcast_replace_to).with(
      @retro,
      has_entries(
        target: "waiting-room-participants",
        partial: "retros/waiting_rooms/participants_section",
        locals: has_entries(retro: @retro)
      )
    )

    @retro.participants.create!(user: users(:two))
  end

  test "participant updates sidebar participant list outside waiting room phase" do
    @retro.update!(phase: :brainstorming)

    Turbo::StreamsChannel.expects(:broadcast_replace_to).with(
      [ @retro, users(:one) ],
      has_entries(
        target: "participant-list",
        partial: "retros/streams/participant_list",
        locals: has_entries(retro: @retro)
      )
    )

    Turbo::StreamsChannel.expects(:broadcast_replace_to).with(
      [ @retro, users(:two) ],
      has_entries(
        target: "participant-list",
        partial: "retros/streams/participant_list",
        locals: has_entries(retro: @retro)
      )
    )

    @retro.participants.create!(user: users(:two))
  end

  test "action updates actions column in discussion phase when published" do
    @retro.update!(phase: :discussion)

    Turbo::StreamsChannel.expects(:broadcast_replace_to).with(
      @retro,
      has_entries(
        target: "actions-column",
        partial: "retros/streams/actions_column",
        locals: has_entries(retro: @retro)
      )
    )

    Action.create!(retro: @retro, user: @user, status: :published)
  end

  test "action updates action review grid in action review phase when published" do
    @retro.update!(phase: :action_review)

    Turbo::StreamsChannel.expects(:broadcast_replace_to).with(
      @retro,
      has_entries(
        target: "action-review-grid",
        partial: "retros/action_reviews/actions_grid",
        locals: has_entries(retro: @retro)
      )
    )

    Action.create!(retro: @retro, user: @user, status: :published)
  end

  test "action does not broadcast when still drafted" do
    @retro.update!(phase: :discussion)
    Turbo::StreamsChannel.expects(:broadcast_replace_to).never

    Action.create!(retro: @retro, user: @user, status: :drafted)
  end

  test "action review grid renders tenant-scoped completion paths" do
    action = Action.create!(retro: @retro, user: @user, status: :published)

    html = ApplicationController.renderer.render(
      partial: "retros/action_reviews/actions_grid",
      locals: { retro: @retro }
    )

    expected_path = Rails.application.routes.url_helpers.retro_action_completion_path(
      @retro,
      action,
      script_name: @retro.account.slug
    )

    assert_includes html, expected_path
  end

  private

  def expect_column_replacements
    Turbo::StreamsChannel.expects(:broadcast_replace_to).with(
      [ @retro, @user ],
      has_entries(
        target: "retro-column-went_well",
        partial: "retros/streams/column",
        locals: has_entries(retro: @retro, category: "went_well")
      )
    )

    Turbo::StreamsChannel.expects(:broadcast_replace_to).with(
      [ @retro, @user ],
      has_entries(
        target: "retro-column-could_be_better",
        partial: "retros/streams/column",
        locals: has_entries(retro: @retro, category: "could_be_better")
      )
    )
  end
end

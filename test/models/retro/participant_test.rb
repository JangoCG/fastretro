require "test_helper"

class Retro::ParticipantTest < ActiveSupport::TestCase
  setup do
    @retro = retros(:one)
    @admin_participant = retro_participants(:one_admin)
  end

  test "cannot demote the last admin" do
    assert_not @admin_participant.update(role: :participant)
    assert_includes @admin_participant.errors.full_messages, "A retro needs at least one moderator."
    assert @admin_participant.reload.admin?
  end

  test "can demote an admin when another admin exists" do
    @retro.participants.create!(user: users(:two), role: :admin)

    assert @admin_participant.update(role: :participant)
    assert @admin_participant.reload.participant?
  end

  test "the sole admin can still update other attributes" do
    @admin_participant.finish!

    assert @admin_participant.reload.finished?
  end

  test "popping balloons adds to the participant total" do
    @admin_participant.pop_balloons(3)
    @admin_participant.pop_balloons(2)

    assert_equal 5, @admin_participant.reload.balloons_popped
  end

  test "popping balloons caps a single batch" do
    @admin_participant.pop_balloons(Retro::Participant::MAX_BALLOON_POPS_PER_REQUEST + 100)

    assert_equal Retro::Participant::MAX_BALLOON_POPS_PER_REQUEST, @admin_participant.reload.balloons_popped
  end

  test "popping balloons broadcasts the highscore without redrawing the participant list" do
    targets = []
    Turbo::StreamsChannel.stubs(:broadcast_replace_to).with do |_stream, options|
      targets << options[:target]
      true
    end

    @admin_participant.pop_balloons(2)

    assert_equal [ BalloonLeaderboardComponent.new(retro: @retro).dom_id ], targets
  end

  test "popping balloons ignores counts that are not positive" do
    @admin_participant.pop_balloons(0)
    @admin_participant.pop_balloons(-5)
    @admin_participant.pop_balloons("nonsense")

    assert_equal 0, @admin_participant.reload.balloons_popped
  end

  test "popping balloons ignores counts that are not a scalar" do
    @admin_participant.pop_balloons([ "1", "2" ])
    @admin_participant.pop_balloons({ "a" => 1 })
    @admin_participant.pop_balloons(nil)

    assert_equal 0, @admin_participant.reload.balloons_popped
  end

  test "role change broadcasts a page refresh to the affected user" do
    participant = @retro.participants.create!(user: users(:two), role: :participant)

    Turbo::StreamsChannel.expects(:broadcast_refresh_to).with([ @retro, users(:two) ])

    participant.update!(role: :admin)
  end

  test "updates without a role change do not broadcast a page refresh" do
    participant = @retro.participants.create!(user: users(:two), role: :participant)

    Turbo::StreamsChannel.expects(:broadcast_refresh_to).never

    participant.finish!
  end
end

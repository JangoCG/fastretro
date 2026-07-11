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

require "test_helper"

class RetroTest < ActiveSupport::TestCase
  setup do
    @retro = retros(:one)
  end

  # === back_phase! tests ===

  test "back_phase! transitions from grouping to brainstorming" do
    @retro.update!(phase: :grouping)

    @retro.back_phase!

    assert_equal "brainstorming", @retro.phase
  end

  test "back_phase! transitions from voting to grouping" do
    @retro.update!(phase: :voting)

    @retro.back_phase!

    assert_equal "grouping", @retro.phase
  end

  test "back_phase! transitions from discussion to voting" do
    @retro.update!(phase: :discussion)

    @retro.back_phase!

    assert_equal "voting", @retro.phase
  end

  test "back_phase! transitions from complete to discussion" do
    @retro.update!(phase: :complete)

    @retro.back_phase!

    assert_equal "discussion", @retro.phase
  end

  test "back_phase! does not transition from brainstorming" do
    @retro.update!(phase: :brainstorming)

    @retro.back_phase!

    assert_equal "brainstorming", @retro.phase
  end

  test "back_phase! does not transition from action_review" do
    @retro.update!(phase: :action_review)

    @retro.back_phase!

    assert_equal "action_review", @retro.phase
  end

  test "back_phase! does not transition from waiting_room" do
    @retro.update!(phase: :waiting_room)

    @retro.back_phase!

    assert_equal "waiting_room", @retro.phase
  end

  test "back_phase! resets highlighted_user_id" do
    @retro.update!(phase: :voting, highlighted_user_id: 123)

    @retro.back_phase!

    assert_nil @retro.highlighted_user_id
  end

  test "back_phase! resets participant finished flags" do
    @retro.update!(phase: :voting)
    participant = @retro.add_participant(users(:one), role: :admin)
    participant.update!(finished: true)

    @retro.back_phase!

    assert_not participant.reload.finished?
  end

  # === previous_phase tests ===

  test "previous_phase returns brainstorming when on grouping" do
    @retro.update!(phase: :grouping)

    assert_equal :brainstorming, @retro.previous_phase
  end

  test "previous_phase returns grouping when on voting" do
    @retro.update!(phase: :voting)

    assert_equal :grouping, @retro.previous_phase
  end

  test "previous_phase returns voting when on discussion" do
    @retro.update!(phase: :discussion)

    assert_equal :voting, @retro.previous_phase
  end

  test "previous_phase returns discussion when on complete" do
    @retro.update!(phase: :complete)

    assert_equal :discussion, @retro.previous_phase
  end

  test "previous_phase returns nil when on brainstorming" do
    @retro.update!(phase: :brainstorming)

    assert_nil @retro.previous_phase
  end

  test "previous_phase returns nil when on action_review" do
    @retro.update!(phase: :action_review)

    assert_nil @retro.previous_phase
  end

  test "previous_phase returns nil when on waiting_room" do
    @retro.update!(phase: :waiting_room)

    assert_nil @retro.previous_phase
  end

  # === can_go_back? tests ===

  test "can_go_back? returns true for grouping" do
    @retro.update!(phase: :grouping)

    assert @retro.can_go_back?
  end

  test "can_go_back? returns true for voting" do
    @retro.update!(phase: :voting)

    assert @retro.can_go_back?
  end

  test "can_go_back? returns true for discussion" do
    @retro.update!(phase: :discussion)

    assert @retro.can_go_back?
  end

  test "can_go_back? returns true for complete" do
    @retro.update!(phase: :complete)

    assert @retro.can_go_back?
  end

  test "can_go_back? returns false for brainstorming" do
    @retro.update!(phase: :brainstorming)

    assert_not @retro.can_go_back?
  end

  test "can_go_back? returns false for action_review" do
    @retro.update!(phase: :action_review)

    assert_not @retro.can_go_back?
  end

  test "can_go_back? returns false for waiting_room" do
    @retro.update!(phase: :waiting_room)

    assert_not @retro.can_go_back?
  end
end

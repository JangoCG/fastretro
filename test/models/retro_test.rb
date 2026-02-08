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

  test "back_phase! clears votes when leaving voting phase" do
    @retro.update!(phase: :voting)
    participant = @retro.add_participant(users(:one), role: :admin)
    feedback = feedbacks(:one)
    Vote.create!(retro_participant: participant, voteable: feedback)

    assert_equal 1, Vote.where(retro_participant: participant).count

    @retro.back_phase!

    assert_equal 0, Vote.where(retro_participant: participant).count
    assert_equal "grouping", @retro.phase
  end

  test "back_phase! does not clear votes when leaving discussion phase" do
    @retro.update!(phase: :discussion)
    participant = @retro.add_participant(users(:one), role: :admin)
    feedback = feedbacks(:one)
    Vote.create!(retro_participant: participant, voteable: feedback)

    @retro.back_phase!

    assert_equal 1, Vote.where(retro_participant: participant).count
    assert_equal "voting", @retro.phase
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

  test "cached_global_count fetches retro count from cache using shared key" do
    Rails.cache.expects(:fetch).with(
      Retro::LANDING_PAGE_RETRO_COUNT_CACHE_KEY,
      expires_in: 12.hours,
      race_condition_ttl: 10.minutes
    ).returns(42)

    assert_equal 42, Retro.cached_global_count
  end

  test "creating retro expires landing page retro count cache" do
    Rails.cache.expects(:delete).with(Retro::LANDING_PAGE_RETRO_COUNT_CACHE_KEY)

    Retro.create!(name: "Cache Test Retro", account: accounts(:one))
  end

  test "destroying retro expires landing page retro count cache" do
    Rails.cache.expects(:delete).with(Retro::LANDING_PAGE_RETRO_COUNT_CACHE_KEY)

    retros(:two).destroy!
  end
end

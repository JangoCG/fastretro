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

  test "back_phase! transitions from discussion to grouping" do
    @retro.update!(phase: :discussion)

    @retro.back_phase!

    assert_equal "grouping", @retro.phase
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
    @retro.update!(phase: :discussion, highlighted_user_id: 123)

    @retro.back_phase!

    assert_nil @retro.highlighted_user_id
  end

  test "back_phase! resets participant finished flags" do
    @retro.update!(phase: :discussion)
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

  test "previous_phase returns grouping when on discussion" do
    @retro.update!(phase: :discussion)

    assert_equal :grouping, @retro.previous_phase
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

  test "default layout exposes two columns" do
    assert_equal "default", @retro.layout_mode
    assert_equal %w[went_well could_be_better], @retro.column_categories
    assert_equal [ "Good", "Bad" ], @retro.column_definitions.map { |column| column["name"] }
  end

  test "configure_column_layout with custom mode normalizes and de-duplicates column ids" do
    @retro.configure_column_layout(
      layout_mode: "custom",
      column_names: [ "Start", "Start", "  ", "Stop" ]
    )
    @retro.save!

    assert_equal "custom", @retro.layout_mode
    assert_equal %w[start start_2 stop], @retro.column_categories
    assert_equal [ "Start", "Start", "Stop" ], @retro.column_definitions.map { |column| column["name"] }
  end

  test "configure_column_layout with default mode ignores supplied column names" do
    @retro.configure_column_layout(layout_mode: "default", column_names: [ "Anything" ])
    @retro.save!

    assert_equal "default", @retro.layout_mode
    assert_equal %w[went_well could_be_better], @retro.column_categories
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

  # === Retro Limit Tests ===

  test "creating retro increments account retros_count in saas mode" do
    enable_saas_mode
    account = accounts(:one)
    account.update!(retros_count: 0)

    assert_difference -> { account.reload.retros_count }, 1 do
      Retro.create!(name: "Limit Test", account: account)
    end
  end

  test "creating retro does not increment retros_count when not in saas mode" do
    disable_saas_mode
    account = accounts(:one)
    account.update!(retros_count: 0)

    assert_no_difference -> { account.reload.retros_count } do
      Retro.create!(name: "Limit Test", account: account)
    end
  end

  private

  def enable_saas_mode
    FastRetro.saas = true
  end

  def disable_saas_mode
    FastRetro.saas = false
  end

  teardown do
    FastRetro.reset_saas!
  end
end

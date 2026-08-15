require "test_helper"

class Retros::BalloonPopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @retro.update!(phase: :complete)
    @participant = retro_participants(:one_admin)
  end

  test "participant records popped balloons" do
    sign_in_as :one

    post retro_balloon_pops_path(@retro), params: { count: 4 }

    assert_response :created
    assert_equal 4, @participant.reload.balloons_popped
  end

  test "pops add up across requests" do
    sign_in_as :one
    @participant.update!(balloons_popped: 7)

    post retro_balloon_pops_path(@retro), params: { count: 3 }

    assert_equal 10, @participant.reload.balloons_popped
  end

  test "pops are capped per request" do
    sign_in_as :one

    post retro_balloon_pops_path(@retro), params: { count: 10_000 }

    assert_equal Retro::Participant::MAX_BALLOON_POPS_PER_REQUEST, @participant.reload.balloons_popped
  end

  test "junk counts are ignored" do
    sign_in_as :one
    Turbo::StreamsChannel.expects(:broadcast_replace_to).never

    post retro_balloon_pops_path(@retro), params: { count: "-5" }

    assert_response :created
    assert_equal 0, @participant.reload.balloons_popped
  end

  test "a count that is not a scalar is turned away instead of blowing up" do
    sign_in_as :one

    without_action_dispatch_exception_handling do
      post retro_balloon_pops_path(@retro), params: { count: [ "1", "2" ] }
    end

    assert_response :created
    assert_equal 0, @participant.reload.balloons_popped
  end

  test "balloons cannot be popped before the retro is complete" do
    sign_in_as :one
    @retro.update!(phase: :discussion)

    post retro_balloon_pops_path(@retro), params: { count: 2 }

    assert_response :unprocessable_entity
    assert_equal 0, @participant.reload.balloons_popped
  end

  test "popping broadcasts the highscore to everyone in the retro" do
    sign_in_as :one
    broadcast = nil
    Turbo::StreamsChannel.stubs(:broadcast_replace_to).with do |retro, options|
      broadcast = [ retro, options ]
      true
    end

    post retro_balloon_pops_path(@retro), params: { count: 1 }

    retro, options = broadcast
    assert_equal @retro, retro
    assert_equal BalloonLeaderboardComponent.new(retro: @retro).dom_id, options[:target]
    assert_includes options[:html], users(:one).name
    # Only the highscore travels over the wire, never a page worth of layout around it.
    assert_not_includes options[:html], "<body"
  end

  test "retro of another account cannot be played" do
    sign_in_as :one

    post retro_balloon_pops_path(retros(:other_account_retro)), params: { count: 1 }

    assert_response :not_found
  end

  test "unauthenticated user cannot pop balloons" do
    post retro_balloon_pops_path(@retro, script_name: nil), params: { count: 1 }

    assert_redirected_to session_menu_path(script_name: nil)
    assert_equal 0, @participant.reload.balloons_popped
  end
end

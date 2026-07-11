require "test_helper"

class Feedbacks::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @feedback = feedbacks(:one)
    @retro.update!(phase: :grouping)
    Turbo::StreamsChannel.stubs(:broadcast_replace_to)
  end

  test "admin moves published feedback to another column" do
    sign_in_as users(:one)

    patch retro_feedback_category_path(@retro, @feedback), params: { category: "could_be_better" }, as: :json

    assert_response :no_content
    assert_equal "could_be_better", @feedback.reload.category
  end

  test "move rejects categories outside the retro layout" do
    sign_in_as users(:one)

    patch retro_feedback_category_path(@retro, @feedback), params: { category: "missing" }, as: :json

    assert_response :unprocessable_entity
    assert_equal "went_well", @feedback.reload.category
  end

  test "move rejects grouped feedback" do
    sign_in_as users(:one)
    @feedback.update!(feedback_group: @retro.feedback_groups.create!)

    patch retro_feedback_category_path(@retro, @feedback), params: { category: "could_be_better" }, as: :json

    assert_response :unprocessable_entity
    assert_equal "went_well", @feedback.reload.category
  end

  test "member cannot move feedback between columns" do
    sign_in_as users(:two)

    patch retro_feedback_category_path(@retro, @feedback), params: { category: "could_be_better" }, as: :json

    assert_response :redirect
    assert_equal "went_well", @feedback.reload.category
  end

  test "participant moves their own feedback during brainstorming" do
    sign_in_as users(:one)
    @retro.update!(phase: :brainstorming)

    patch retro_feedback_category_path(@retro, @feedback), params: { category: "could_be_better" }, as: :json

    assert_response :no_content
    assert_equal "could_be_better", @feedback.reload.category
  end

  test "participant cannot move another user's feedback during brainstorming" do
    sign_in_as users(:two)
    @retro.update!(phase: :brainstorming)

    patch retro_feedback_category_path(@retro, @feedback), params: { category: "could_be_better" }, as: :json

    assert_response :redirect
    assert_equal "went_well", @feedback.reload.category
  end

  test "feedback cannot move outside the grouping phase" do
    sign_in_as users(:one)
    @retro.update!(phase: :voting)

    patch retro_feedback_category_path(@retro, @feedback), params: { category: "could_be_better" }, as: :json

    assert_response :redirect
    assert_equal "went_well", @feedback.reload.category
  end
end

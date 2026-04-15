require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  setup do
    @retro = retros(:one)
    @owner_identity = identities(:one)
    @user = users(:one)
    Current.user = @user
  end

  test "publish changes status to published" do
    feedback = Feedback.create!(retro: @retro, user: @user, category: :went_well, status: :drafted)

    feedback.publish

    assert feedback.published?
  end
end

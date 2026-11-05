require "test_helper"
require "csv"

class Retros::ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    sign_in_as :one
  end

  test "csv keeps feedback and action text as written" do
    text = %(Don't say "later" & a < b)
    @retro.feedbacks.create!(user: users(:one), category: "went_well", content: ERB::Util.h(text), status: :published)
    @retro.actions.create!(user: users(:one), content: ERB::Util.h(text), status: :published)

    get retro_export_path(@retro, format: :csv)

    assert_response :success
    assert_equal 2, CSV.parse(response.body).flatten.count(text)
  end
end

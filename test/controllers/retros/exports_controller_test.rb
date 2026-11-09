require "test_helper"
require "csv"
require "zip"

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

  test "xlsx contains both worksheets and preserves published feedback and action text" do
    text = %(Don't say "later" & a < b — résumé)
    @retro.feedbacks.create!(user: users(:one), category: "went_well", content: ERB::Util.h(text), status: :published)
    @retro.actions.create!(user: users(:one), content: ERB::Util.h(text), status: :published)
    @retro.feedbacks.create!(user: users(:one), category: "went_well", content: "Unpublished export secret", status: :drafted)

    get retro_export_path(@retro, format: :xlsx)

    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type
    Zip::File.open_buffer(response.body) do |archive|
      namespace = { "s" => "http://schemas.openxmlformats.org/spreadsheetml/2006/main" }
      workbook = Nokogiri::XML(archive.read("xl/workbook.xml"))
      assert_equal [ "Feedbacks", "Action Items" ], workbook.xpath("//s:sheet/@name", namespace).map(&:value)
      %w[ sheet1 sheet2 ].each do |sheet|
        document = Nokogiri::XML(archive.read("xl/worksheets/#{sheet}.xml"))
        cells = document.xpath("//s:c//s:t", namespace).map(&:text)
        assert_includes cells, text
        assert_not_includes cells, "Unpublished export secret"
      end
    end
  end
end

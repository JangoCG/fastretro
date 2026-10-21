require "test_helper"
require "zip"

class Retros::ExportsControllerTest < ActionDispatch::IntegrationTest
  test "Excel exports contain feedback and action items" do
    retro = retros(:one)
    feedbacks(:one).update!(content: "A useful retrospective")
    retro.actions.create!(user: users(:one), content: "Document the release", status: :published)
    sign_in_as :one

    get retro_export_path(retro, format: :xlsx)

    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type

    Zip::File.open_buffer(response.body) do |archive|
      workbook = Nokogiri::XML(archive.read("xl/workbook.xml")).remove_namespaces!
      assert_equal [ "Feedbacks", "Action Items" ], workbook.xpath("//sheet").map { |sheet| sheet["name"] }

      feedbacks = Nokogiri::XML(archive.read("xl/worksheets/sheet1.xml")).remove_namespaces!
      actions = Nokogiri::XML(archive.read("xl/worksheets/sheet2.xml")).remove_namespaces!
      assert_includes feedbacks.xpath("//t").map(&:text), "A useful retrospective"
      assert_includes actions.xpath("//t").map(&:text), "Document the release"
    end
  end
end

require "test_helper"

class UnprocessableRepresentationTest < ActionDispatch::IntegrationTest
  setup do
    retros(:one).update!(phase: :grouping)
    @blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("not an image"), filename: "image.png", content_type: "image/png", identify: false)
    feedbacks(:one).update!(content: ActionText::Attachment.from_attachable(@blob).to_html)
    sign_in_as :one
  end

  teardown { @blob.purge }

  test "permanent failures are reported once as handled and return 422" do
    ActiveStorage::Variation.any_instance.stubs(:transform).raises(FastRetro::Cell::UnprocessableAttachment.new("killed: fsize"))
    reports = []
    subscriber = Object.new
    subscriber.define_singleton_method(:report) { |error, **details| reports << [ error, details ] }
    Rails.error.subscribe(subscriber)

    get rails_representation_path(@blob.representation(resize_to_limit: [ 10, 10 ]))

    assert_response :unprocessable_entity
    assert_equal 1, reports.size
    assert_kind_of FastRetro::Cell::UnprocessableAttachment, reports.first.first
    assert_equal true, reports.first.last[:handled]
    assert_equal :info, reports.first.last[:severity]
  ensure
    Rails.error.unsubscribe(subscriber)
  end

  test "transient failures raise for retry rather than returning a permanent verdict" do
    ActiveStorage::Variation.any_instance.stubs(:transform).raises(FastRetro::Cell::ProcessingUnavailable.new("capacity"))

    assert_raises FastRetro::Cell::ProcessingUnavailable do
      get rails_representation_path(@blob.representation(resize_to_limit: [ 10, 10 ]))
    end
  end
end

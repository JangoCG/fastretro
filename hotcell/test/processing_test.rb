require "test_helper"
require "base64"

class HotcellProcessingTest < ActiveSupport::TestCase
  PNG = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")

  setup do
    assert FastRetro::Cell.enabled?, "Run this test through hotcell/bin/test"
  end

  test "image metadata and variants are processed by the cell" do
    blob = create_blob(PNG)
    blob.analyze

    assert_equal 1, blob.metadata["width"]
    assert_equal 1, blob.metadata["height"]
    variant = blob.variant(resize_to_limit: [ 10, 10 ]).processed
    assert_equal "image/png", variant.content_type
    assert_operator variant.download.bytesize, :>, 0
  ensure
    blob&.purge
  end

  test "an unreadable file is a permanent failure" do
    blob = create_blob("not an image")

    assert_raises FastRetro::Cell::UnprocessableAttachment do
      blob.variant(resize_to_limit: [ 10, 10 ]).processed
    end
  ensure
    blob&.purge
  end

  test "an unavailable cell does not fall back to local image processing" do
    blob = create_blob(PNG)
    original_root = HotCell.root
    HotCell.root = Rails.root.join("tmp/missing-hotcell").to_s

    assert_raises FastRetro::Cell::ProcessingUnavailable do
      blob.variant(resize_to_limit: [ 10, 10 ]).processed
    end
  ensure
    HotCell.root = original_root
    blob&.purge
  end

  private
    def create_blob(contents)
      ActiveStorage::Blob.create_and_upload! io: StringIO.new(contents), filename: "diagram.png",
        content_type: "image/png", identify: false
    end
end

class HotcellRepresentationTest < ActionDispatch::IntegrationTest
  test "requesting an unreadable image returns 422" do
    blob = ActiveStorage::Blob.create_and_upload! io: StringIO.new("not an image"), filename: "invalid.png",
      content_type: "image/png", identify: false

    get rails_storage_proxy_path(blob.variant(resize_to_limit: [ 10, 10 ]))

    assert_response :unprocessable_entity
  ensure
    blob&.purge
  end
end

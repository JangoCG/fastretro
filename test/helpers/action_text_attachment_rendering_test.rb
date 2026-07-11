require "test_helper"
require "base64"

class ActionTextAttachmentRenderingTest < ActionView::TestCase
  test "animated gifs render the original blob" do
    blob = create_blob(
      Base64.decode64("R0lGODlhAQABAAAAACwAAAAAAQABAAA="),
      filename: "celebration.gif",
      content_type: "image/gif"
    )

    output = render partial: "active_storage/blobs/blob", locals: { blob: blob }

    assert_select "figure.attachment--gif img[src*='/rails/active_storage/blobs/']"
    assert_no_match "/rails/active_storage/representations/", output
  ensure
    blob&.purge
  end

  test "other images render optimized representations" do
    blob = create_blob(
      Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="),
      filename: "diagram.png",
      content_type: "image/png"
    )

    render partial: "active_storage/blobs/blob", locals: { blob: blob }

    assert_select "figure.attachment--png img[src*='/rails/active_storage/representations/']"
  ensure
    blob&.purge
  end

  private
    def create_blob(contents, filename:, content_type:)
      ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(contents),
        filename: filename,
        content_type: content_type,
        identify: false
      )
    end
end

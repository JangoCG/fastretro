require "test_helper"

class ActiveStorageServedContentTypesTest < ActionDispatch::IntegrationTest
  setup do
    @blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("data"), filename: "image.png", content_type: "image/png", identify: false)
    @feedback = feedbacks(:one)
    @feedback.update!(content: ActionText::Attachment.from_attachable(@blob).to_html)
    sign_in_as :one
  end

  teardown do
    @feedback.rich_text_content.embeds.destroy_all
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob) { @blob.purge }
  end

  test "unknown executable and document types are binary downloads with nosniff" do
    [ "text/javascript", "application/javascript", "application/x-javascript", "text/ecmascript",
      "text/jscript", "text/x-javascript", "application/json", "text/css", "text/plain", "text/csv",
      "text/html", "text/x-html", "text/vnd.turbo-stream.html", "application/xhtml+xml+foo", "image/svg+xml",
      "application/xml", "text/html;charset=utf-8", "text/htmlé", "application/x-unrecognized", "", nil ].each do |type|
      serve type
      assert_equal "application/octet-stream", response.media_type, type.inspect
      assert_equal "nosniff", response.headers["X-Content-Type-Options"]
      assert_match(/\Aattachment\b/, response.headers["Content-Disposition"])
    end
  end

  test "a type outside the list cannot request inline display" do
    serve "text/javascript", disposition: :inline
    assert_equal "application/octet-stream", response.media_type
    assert_match(/\Aattachment\b/, response.headers["Content-Disposition"])
  end

  test "misspelled parameterized mixed and malformed types cannot bypass the list" do
    [ "Text/JavaScript", "text/javascript; charset=utf-8", "text/plain; x=video/mp4", "video/mp4,text/javascript",
      "image/png,text/html", "video/mp4; codecs=a,text/javascript", "video/mp4 text/javascript",
      "image/png\r\nX-Other: value", "image/png; x=\r\nX-Other: value", "video/mp4\u0000", "video/mKv", "image/png; x=é" ].each do |type|
      blob = ActiveStorage::Blob.new(content_type: type)
      assert_equal "application/octet-stream", blob.content_type_for_serving, type.inspect
      assert_equal :attachment, blob.forced_disposition_for_serving, type.inspect
    end
  end

  test "recognized types retain their declared media type and images remain inline" do
    %w[ image/png image/jpeg image/gif image/webp image/avif application/pdf ].each do |type|
      serve type, disposition: :inline
      assert_equal type, response.media_type
      assert_match(/\Ainline\b/, response.headers["Content-Disposition"])
    end
    %w[ audio/mpeg audio/ogg audio/mp4 video/mp4 video/webm video/quicktime image/heic image/heif application/zip ].each do |type|
      serve type
      assert_equal type, response.media_type
    end
    [ "audio/ogg; codecs=opus", "Image/PNG", " image/png " ].each do |type|
      assert_equal type, ActiveStorage::Blob.new(content_type: type).content_type_for_serving
    end
  end

  test "the Rails binary deny-list still overrides a recognized type" do
    original = ActiveStorage.content_types_to_serve_as_binary
    ActiveStorage.content_types_to_serve_as_binary = original + [ "image/png" ]
    blob = ActiveStorage::Blob.new(content_type: "image/png")
    assert_equal "application/octet-stream", blob.content_type_for_serving
    assert_equal :attachment, blob.forced_disposition_for_serving
  ensure
    ActiveStorage.content_types_to_serve_as_binary = original
  end

  private
    def serve(type, **options)
      # Existing/internal blob declarations need safe serving even when they would fail today's upload validation.
      @blob.update_column(:content_type, type)
      get rails_blob_path(@blob, **options)
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
end

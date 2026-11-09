require "test_helper"
require "base64"

class UnprocessableAttachmentTest < ActiveSupport::TestCase
  setup do
    @reflection = ActionText::RichText.reflect_on_attachment(:embeds)
    @variants = @reflection.named_variants.dup
    @reflection.variant :small, resize_to_limit: [ 10, 10 ], process: :immediately
    @reflection.variant :large, resize_to_limit: [ 20, 20 ], process: :immediately
    feedbacks(:one).update!(content: "An image upload")
    @blob = ActiveStorage::Blob.build_after_unfurling(io: StringIO.new(image_bytes), filename: "image.png", content_type: "image/png")
    @blob.save!
    @attachment = ActiveStorage::Attachment.new(record: feedbacks(:one).content, name: "embeds", blob: @blob)
  end

  teardown do
    @reflection.named_variants.replace(@variants)
    @blob.purge
  end

  test "form uploads retain the original and attempt every immediate variant after a permanent failure" do
    ActiveStorage::Variation.any_instance.expects(:transform).twice.raises(FastRetro::Cell::UnprocessableAttachment.new("killed: fsize"))
    Rails.error.expects(:report).with { |error, handled:, severity:, **| error.is_a?(FastRetro::Cell::UnprocessableAttachment) && handled && severity == :info }.twice

    assert_no_enqueued_jobs(only: [ ActiveStorage::CreateVariantsJob, ActiveStorage::TransformJob ]) do
      @attachment.uploaded(io: StringIO.new(image_bytes))
    end

    assert_equal image_bytes, @blob.download.b
  end

  test "immediate variants are processed from the uploaded image" do
    assert_difference "ActiveStorage::VariantRecord.count", 2 do
      @attachment.uploaded(io: StringIO.new(image_bytes))
    end

    assert_equal image_bytes, @blob.download.b
  end

  private
    def image_bytes
      Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")
    end
end

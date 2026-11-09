require "test_helper"

class VipsConfigurationTest < ActiveSupport::TestCase
  test "image processing uses bounded workers and caches" do
    assert_equal 4, Vips.concurrency
    assert_equal 10, Vips.cache_max
    assert_equal 10.megabytes, Vips.cache_max_mem
    assert_equal 10, Vips.cache_max_files
  end

  test "TIFF uploads cannot be transformed even if a variant is requested directly" do
    file = Tempfile.new([ "image", ".tiff" ])
    Vips::Image.black(1, 1).write_to_file(file.path)
    assert_raises Vips::Error do
      ImageProcessing::Vips.source(file.path).resize_to_limit(10, 10).call
    end
  ensure
    file&.close!
  end

  test "risky formats are ineligible for variants while PNG still transforms" do
    %w[ image/bmp image/tiff image/vnd.microsoft.icon image/vnd.adobe.photoshop ].each do |content_type|
      blob = ActiveStorage::Blob.new(content_type: content_type)
      assert_not blob.variable?
    end
    file = Tempfile.new([ "image", ".png" ])
    Vips::Image.black(2, 2).write_to_file(file.path)
    result = ImageProcessing::Vips.source(file.path).resize_to_limit(1, 1).convert("png").call
    assert_equal 1, Vips::Image.new_from_file(result.path).width
  ensure
    result&.close!
    file&.close!
  end
end

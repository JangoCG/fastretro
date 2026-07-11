require "test_helper"
require "digest/md5"

class ActiveStorageDirectUploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "direct uploads are handled by active storage under account paths" do
    assert_difference -> { ActiveStorage::Blob.count } do
      post_direct_upload filename: "avatar.png", content_type: "image/png"
    end

    assert_response :success
    assert_not_nil response.parsed_body["signed_id"]
    assert_equal "avatar.png", response.parsed_body["filename"]
  end

  test "direct uploads accept animated gifs" do
    assert_difference -> { ActiveStorage::Blob.where(content_type: "image/gif").count } do
      post_direct_upload filename: "celebration.gif", content_type: "image/gif"
    end

    assert_response :success
  end

  test "direct uploads reject non-image content" do
    assert_no_difference -> { ActiveStorage::Blob.count } do
      post_direct_upload filename: "payload.html", content_type: "text/html"
    end

    assert_response :unprocessable_entity
  end

  test "direct uploads reject images larger than ten megabytes" do
    assert_no_difference -> { ActiveStorage::Blob.count } do
      post_direct_upload filename: "huge.gif", content_type: "image/gif", byte_size: 10.megabytes + 1
    end

    assert_response :unprocessable_entity
  end

  test "direct uploads require authentication" do
    sign_out

    assert_no_difference -> { ActiveStorage::Blob.count } do
      post_direct_upload filename: "anonymous.gif", content_type: "image/gif"
    end

    assert_response :redirect
  end

  private
    def post_direct_upload(filename:, content_type:, byte_size: 1)
      post "#{accounts(:one).slug}/rails/active_storage/direct_uploads", params: {
        blob: {
          filename: filename,
          byte_size: byte_size,
          checksum: Digest::MD5.base64digest("x"),
          content_type: content_type
        }
      }, as: :json
    end
end

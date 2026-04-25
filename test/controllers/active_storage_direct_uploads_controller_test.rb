require "test_helper"
require "digest/md5"

class ActiveStorageDirectUploadsControllerTest < ActionDispatch::IntegrationTest
  test "direct uploads are handled by active storage under account paths" do
    assert_difference -> { ActiveStorage::Blob.count } do
      post "#{accounts(:one).slug}/rails/active_storage/direct_uploads", params: {
        blob: {
          filename: "avatar.png",
          byte_size: 1,
          checksum: Digest::MD5.base64digest("x"),
          content_type: "image/png"
        }
      }, as: :json
    end

    assert_response :success
    assert_not_nil response.parsed_body["signed_id"]
    assert_equal "avatar.png", response.parsed_body["filename"]
  end
end

require "test_helper"
require "base64"

class ActiveStorageAuthorizationTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  setup do
    @blobs = []
    @retro = retros(:one)
    @retro.update!(phase: :grouping)
    @feedback = feedbacks(:one)
    @blob = create_blob
    @feedback.update!(content: ActionText::Attachment.from_attachable(@blob).to_html)
  end

  teardown do
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob) { @blobs.each(&:purge) }
  end

  test "account members can download published feedback images and previews" do
    sign_in_as users(:two)

    get rails_blob_path(@blob)
    assert_response :redirect
    assert_match "/rails/active_storage/disk/", response.location

    follow_redirect!
    assert_response :success
    assert_equal image_bytes, response.body.b

    representation = @blob.representation(resize_to_limit: [ 100, 100 ])
    get rails_representation_path(representation)
    assert_response :redirect
    assert_not_includes response.headers["Cache-Control"], "public"
    follow_redirect!
    assert_response :success
  end

  test "anonymous requests cannot download or process private images" do
    paths = download_paths

    assert_no_difference "ActiveStorage::VariantRecord.count" do
      paths.each do |path|
        get path
        assert_redirected_to root_path(script_name: nil)
      end
    end
  end

  test "members of another account cannot download or process private images" do
    sign_in_as users(:other_account_owner)
    integration_session.default_url_options = integration_session.default_url_options.merge(script_name: accounts(:two).slug)

    assert_no_difference "ActiveStorage::VariantRecord.count" do
      download_paths.each do |path|
        get path
        assert_response :forbidden
      end
    end
  end

  test "proxy routes answer not found before lookup authorization or representation processing" do
    paths = [ rails_storage_proxy_path(@blob), rails_storage_proxy_path(@blob.representation(resize_to_limit: [ 100, 100 ])),
      "#{accounts(:one).slug}/rails/active_storage/blobs/proxy/invalid/image.png",
      "#{accounts(:one).slug}/rails/active_storage/representations/proxy/invalid/invalid/image.png" ]
    assert_no_difference "ActiveStorage::VariantRecord.count" do
      paths.each do |path|
        get path
        assert_response :not_found
      end
      sign_in_as :one
      paths.each do |path|
        get path
        assert_response :not_found
      end
    end
  end

  test "unpublished feedback images are only accessible to their author" do
    @feedback.update!(status: :drafted)
    sign_in_as users(:two)

    get rails_blob_path(@blob)
    assert_response :forbidden

    logout_and_sign_in_as users(:one)
    get rails_blob_path(@blob)
    assert_response :redirect
    assert_match "/rails/active_storage/disk/", response.location
  end

  test "published brainstorming images remain private to their author" do
    @retro.update!(phase: :brainstorming)
    sign_in_as users(:two)

    get rails_blob_path(@blob)
    assert_response :forbidden

    logout_and_sign_in_as users(:one)
    get rails_blob_path(@blob)
    assert_response :redirect
    assert_match "/rails/active_storage/disk/", response.location
  end

  test "action images follow publication and author access" do
    action = @retro.actions.create!(user: users(:one), status: :drafted,
      content: ActionText::Attachment.from_attachable(@blob).to_html)
    @feedback.update!(content: "Image moved to action")
    sign_in_as users(:two)

    get rails_blob_path(@blob)
    assert_response :forbidden

    logout_and_sign_in_as users(:one)
    get rails_blob_path(@blob)
    assert_response :redirect

    action.publish
    logout_and_sign_in_as users(:two)
    get rails_blob_path(@blob)
    assert_response :redirect
    assert_match "/rails/active_storage/disk/", response.location
  end

  test "unattached uploads are only accessible inside the uploading account" do
    sign_in_as users(:one)
    post "#{accounts(:one).slug}/rails/active_storage/direct_uploads", params: {
      blob: { filename: "preview.png", content_type: "image/png", byte_size: 1, checksum: Digest::MD5.base64digest("x") }
    }, as: :json
    assert_response :success
    blob = ActiveStorage::Blob.find_signed!(response.parsed_body.fetch("signed_id"))
    @blobs << blob
    assert_equal accounts(:one).id, blob.account_id

    get rails_blob_path(blob)
    assert_response :redirect
    assert_match "/rails/active_storage/disk/", response.location

    users(:one).update!(active: false)
    get rails_blob_path(blob)
    assert_response :forbidden
    users(:one).update!(active: true)

    blob.update_column(:account_id, nil)
    get rails_blob_path(blob)
    assert_response :forbidden
    blob.update_column(:account_id, accounts(:one).id)

    logout_and_sign_in_as users(:other_account_owner)
    get rails_blob_path(blob, script_name: accounts(:two).slug)
    assert_response :forbidden
  end

  test "deactivated members cannot use existing image links" do
    sign_in_as users(:one)
    users(:one).update!(active: false)

    get rails_blob_path(@blob)
    assert_response :forbidden
  end

  test "existing attached images without an account column value remain accessible" do
    @blob.update_column(:account_id, nil)
    sign_in_as users(:one)

    get rails_blob_path(@blob)
    assert_response :redirect
    assert_match "/rails/active_storage/disk/", response.location
  end

  test "broadcast images keep their account path prefix" do
    user = users(:one)
    stream = [ @retro, user ].map(&:to_gid_param).join(":")

    messages = capture_broadcasts(stream) do
      Current.set(account: @retro.account, user:) do
        Turbo::StreamsChannel.broadcast_replace_to([ @retro, user ], target: "image",
          partial: "active_storage/blobs/blob", locals: { blob: @blob })
      end
    end

    assert_equal 1, messages.size
    document = Nokogiri::HTML.fragment(messages.first)
    assert_match %r{\A#{accounts(:one).slug}/rails/active_storage/}, document.at_css("img")["src"]
  end

  test "a signed image cannot be attached to feedback in another account" do
    other_user = users(:other_account_owner)
    other_retro = retros(:other_account_retro)
    other_feedback = other_retro.feedbacks.create!(user: other_user, category: :went_well)
    sign_in_as other_user

    assert_no_difference -> { @blob.attachments.count } do
      patch retro_feedback_path(other_retro, other_feedback, script_name: accounts(:two).slug),
        params: { feedback: { content: ActionText::Attachment.from_attachable(@blob).to_html } }
    end

    assert_response :unprocessable_entity
    assert_empty other_feedback.reload.content.embeds
  end

  private
    def create_blob
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(image_bytes), filename: "image.png", content_type: "image/png", identify: false)
      @blobs << blob
      blob
    end

    def image_bytes
      Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")
    end

    def download_paths
      representation = @blob.representation(resize_to_limit: [ 100, 100 ])
      [ rails_blob_path(@blob), rails_representation_path(representation) ]
    end
end

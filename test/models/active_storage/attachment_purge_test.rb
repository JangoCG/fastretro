require "test_helper"

class ActiveStorage::AttachmentPurgeTest < ActiveSupport::TestCase
  setup do
    @blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("image"), filename: "image.png", content_type: "image/png", identify: false)
    @html = ActionText::Attachment.from_attachable(@blob).to_html
    feedbacks(:one).update!(content: @html)
  end

  teardown do
    @blob.attachments.destroy_all if @blob.persisted?
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob) { @blob.purge }
  end

  test "removing a reused image neither purges nor queues a purge until its last attachment is gone" do
    feedbacks(:two).update!(content: @html)
    first = feedbacks(:one).rich_text_content.embeds.sole
    last = feedbacks(:two).rich_text_content.embeds.sole

    updated_at = feedbacks(:one).updated_at
    travel 1.second do
      assert_no_enqueued_jobs only: ActiveStorage::PurgeJob do
        first.purge_later
      end
    end
    assert feedbacks(:one).reload.updated_at > updated_at
    assert_equal "image", @blob.download
    assert last.reload

    assert_enqueued_jobs 1, only: ActiveStorage::PurgeJob do
      last.purge_later
    end
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob)
    assert_not ActiveStorage::Blob.exists?(@blob.id)
    assert_not @blob.service.exist?(@blob.key)
  end

  test "editing rich text preserves a shared file and cleans up after its last use" do
    feedbacks(:two).update!(content: @html)
    assert_no_enqueued_jobs only: ActiveStorage::PurgeJob do
      feedbacks(:one).update!(content: "Image removed")
    end
    assert_equal "image", @blob.download
    assert_enqueued_jobs 1, only: ActiveStorage::PurgeJob do
      feedbacks(:two).update!(content: "Image removed")
    end
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob)
    assert_not ActiveStorage::Blob.exists?(@blob.id)
    assert_not @blob.service.exist?(@blob.key)
  end

  test "synchronous purge retains a reused file and deletes it on the last removal" do
    feedbacks(:two).update!(content: @html)
    assert_no_enqueued_jobs only: ActiveStorage::PurgeJob do
      feedbacks(:one).rich_text_content.embeds.sole.purge
    end
    assert_equal "image", @blob.download
    feedbacks(:two).rich_text_content.embeds.sole.purge
    assert_not ActiveStorage::Blob.exists?(@blob.id)
    assert_not @blob.service.exist?(@blob.key)
  end

  test "destroying an orphaned attachment can still schedule cleanup" do
    attachment = feedbacks(:one).rich_text_content.embeds.sole
    feedbacks(:one).rich_text_content.delete
    attachment.reload
    assert_enqueued_with job: ActiveStorage::PurgeJob, args: [ @blob ] do
      attachment.destroy!
    end
  end
end

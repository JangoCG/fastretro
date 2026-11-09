require "test_helper"
require "base64"

class ActiveStorageJobsTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  setup do
    @blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=")),
      filename: "image.png", content_type: "image/png", identify: false
    )
  end

  teardown do
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob) { @blob.purge }
  end

  test "analysis skips images whose attachments have been removed" do
    @blob.service.delete(@blob.key)

    ActiveStorage::AnalyzeJob.perform_now(@blob)

    assert_not @blob.reload.analyzed?
  end

  test "analysis still identifies an attached image" do
    feedbacks(:one).update!(content: ActionText::Attachment.from_attachable(@blob).to_html)

    ActiveStorage::AnalyzeJob.perform_now(@blob)

    assert @blob.reload.analyzed?
    assert_equal 1, @blob.metadata["width"]
    assert_equal 1, @blob.metadata["height"]
  end

  test "analysis updates feedback metadata without broadcasting and subsequent edits still broadcast" do
    retros(:one).update!(phase: :grouping)
    feedback = feedbacks(:one)
    feedback.update!(content: ActionText::Attachment.from_attachable(@blob).to_html)

    assert_no_broadcasts([ retros(:one), users(:one) ].map(&:to_gid_param).join(":")) do
      ActiveStorage::AnalyzeJob.perform_now(@blob)
    end
    assert @blob.reload.analyzed?
    assert_equal 1, @blob.metadata["width"]
    assert_broadcasts([ retros(:one), users(:one) ].map(&:to_gid_param).join(":"), 2) { feedback.update!(content: "New feedback") }
  end

  test "analysis updates action metadata without broadcasting and subsequent edits still broadcast" do
    retro = retros(:one)
    retro.update!(phase: :discussion)
    action = retro.actions.create!(user: users(:one), status: :published, content: ActionText::Attachment.from_attachable(@blob).to_html)

    assert_no_broadcasts(retro.to_gid_param) { ActiveStorage::AnalyzeJob.perform_now(@blob) }
    assert @blob.reload.analyzed?
    assert_broadcasts(retro.to_gid_param, 1) { action.update!(content: "New action") }
  end

  test "analysis failures restore both kinds of retro broadcasts" do
    retro = retros(:one)
    retro.update!(phase: :discussion)
    feedback = feedbacks(:one)
    feedback.update!(content: ActionText::Attachment.from_attachable(@blob).to_html)
    action = retro.actions.create!(user: users(:one), status: :published, content: ActionText::Attachment.from_attachable(@blob).to_html)
    @blob.service.delete(@blob.key)

    assert_raises ActiveStorage::FileNotFoundError do
      ActiveStorage::AnalyzeJob.perform_now(@blob)
    end
    stream = [ retro, users(:one) ].map(&:to_gid_param).join(":")
    assert_broadcasts(stream, 2) { feedback.update!(content: "Feedback after failure") }
    assert_broadcasts(retro.to_gid_param, 1) { action.update!(content: "Action after failure") }
  end

  test "transforming a deleted image is discarded and reported without retrying" do
    @blob.service.delete(@blob.key)
    reports = []
    subscriber = Object.new
    subscriber.define_singleton_method(:report) { |error, **| reports << error }
    Rails.error.subscribe(subscriber)

    assert_no_enqueued_jobs do
      ActiveStorage::TransformJob.perform_now(@blob, resize_to_limit: [ 100, 100 ])
    end

    assert_equal 1, reports.size
    assert_kind_of ActiveStorage::FileNotFoundError, reports.first
  ensure
    Rails.error.unsubscribe(subscriber)
  end

  test "transforming a present image still creates a variant" do
    assert_difference "ActiveStorage::VariantRecord.count", 1 do
      ActiveStorage::TransformJob.perform_now(@blob, resize_to_limit: [ 100, 100 ])
    end
  end

  test "transform jobs discard and report permanent Hotcell failures without retrying" do
    ActiveStorage::Variation.any_instance.stubs(:transform).raises(FastRetro::Cell::UnprocessableAttachment.new("killed: fsize"))
    Rails.error.expects(:report).with { |error, **| error.is_a?(FastRetro::Cell::UnprocessableAttachment) }.twice

    assert_no_enqueued_jobs do
      ActiveStorage::TransformJob.perform_now(@blob, resize_to_limit: [ 10, 10 ])
      ActiveStorage::CreateVariantsJob.perform_now(@blob, variants: [ { resize_to_limit: [ 20, 20 ] } ], process: :immediately)
    end
  end

  test "creating variants discards and reports missing storage files without retrying" do
    ActiveStorage::CreateVariantsJob.any_instance.stubs(:perform).raises(ActiveStorage::FileNotFoundError)
    Rails.error.expects(:report).with { |error, **| error.is_a?(ActiveStorage::FileNotFoundError) }

    assert_no_enqueued_jobs do
      assert_nothing_raised do
        ActiveStorage::CreateVariantsJob.perform_now @blob, variants: [ { resize_to_limit: [ 100, 100 ] } ], process: :immediately
      end
    end
  end
end

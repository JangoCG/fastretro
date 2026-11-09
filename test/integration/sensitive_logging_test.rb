require "test_helper"
require "active_storage/service/s3_service"
require "open3"

class SensitiveLoggingTest < ActionDispatch::IntegrationTest
  test "consumers registered before boot never receive SQL or mail credentials" do
    script = <<~RUBY
      require "bundler/setup"
      require "active_support"
      require "active_support/notifications"
      require "json"

      captured = { sql: [], mail: [] }
      ActiveSupport::Notifications.subscribe("sql.active_record") do |event|
        sql = event.payload[:sql]
        captured[:sql] << sql.dup if sql.include?("magic_links")
      end
      ActiveSupport::Notifications.subscribe("deliver.action_mailer") do |event|
        captured[:mail] << event.payload[:mail].dup
      end

      require_relative "config/environment"
      connection = ActiveRecord::Base.connection
      connection.create_table(:magic_links) { |table| table.string :code }
      connection.execute("INSERT INTO magic_links (code) VALUES ('made-up-boot-secret')")

      class BootRedactionMailer < ActionMailer::Base
        def probe
          mail(from: "sender@example.com", to: "recipient@example.com",
            subject: "made-up-boot-secret", body: "made-up-boot-secret")
        end
      end
      BootRedactionMailer.probe.deliver_now
      puts JSON.generate(captured)
    RUBY
    output, status = Open3.capture2e({ "RAILS_ENV" => "test", "SAAS" => "false", "DATABASE_URL" => "sqlite3::memory:",
      "SKIP_TELEMETRY" => "true", "SENTRY_DSN" => nil, "DISABLE_BOOTSNAP" => "1" },
      RbConfig.ruby, "-e", script, chdir: Rails.root)

    assert status.success?, output
    captured = JSON.parse(output.lines.last)
    assert captured.fetch("sql").any? { |sql| sql.include?("[FILTERED]") }
    assert_equal [ "[FILTERED]" ], captured.fetch("mail")
    assert_not_includes captured.inspect, "made-up-boot-secret"
  end

  test "sign in codes are filtered from request logs and record inspection" do
    log = StringIO.new
    original_logger = ActionController::Base.logger
    ActionController::Base.logger = ActiveSupport::Logger.new(log)

    untenanted do
      post session_magic_link_path, params: { code: "SECRET-SIGN-IN-CODE" }
    end

    assert_includes log.string, '"code" => "[FILTERED]"'
    assert_not_includes log.string, "SECRET-SIGN-IN-CODE"
    assert_includes MagicLink.new(code: "SECRET-SIGN-IN-CODE").inspect, "[FILTERED]"
    assert_not_includes MagicLink.new(code: "SECRET-SIGN-IN-CODE").inspect, "SECRET-SIGN-IN-CODE"
  ensure
    ActionController::Base.logger = original_logger
  end

  test "generated storage URLs keep working signatures without logging them" do
    service = ActiveStorage::Service::S3Service.new(
      bucket: "test-bucket", region: "us-east-1", endpoint: "https://storage.example.com", force_path_style: true,
      access_key_id: "test-access-key", secret_access_key: "test-secret-key"
    )
    service.name = :test_s3
    log = StringIO.new
    original_logger = ActiveStorage.logger
    ActiveStorage.logger = ActiveSupport::Logger.new(log)

    [
      -> { service.url("test-key", expires_in: 5.minutes, filename: ActiveStorage::Filename.new("image.png"), disposition: :inline, content_type: "image/png") },
      -> { service.url_for_direct_upload("test-key", expires_in: 5.minutes, content_type: "image/png", content_length: 1, checksum: "test-checksum") }
    ].each do |generate_url|
      url = generate_url.call
      signature = Rack::Utils.parse_query(URI.parse(url).query).fetch("X-Amz-Signature")

      assert_match(/\A\h{64}\z/, signature)
      assert_includes log.string, "X-Amz-Signature=[FILTERED]"
      assert_not_includes log.string, signature
      assert_includes log.string, "X-Amz-Expires=300"
    end
  ensure
    ActiveStorage.logger = original_logger
  end

  test "redirects to storage preserve the signature but filter the logged location" do
    blob = ActiveStorage::Blob.create_before_direct_upload!(filename: "image.png", byte_size: 1,
      checksum: Digest::MD5.base64digest("x"), content_type: "image/png")
    location = "https://storage.example.com/image.png?X-Amz-Expires=300&X-Amz-Signature=secret-signature"
    ActiveStorage::Blob.any_instance.stubs(:url).returns(location)
    log = StringIO.new
    original_logger = ActionController::Base.logger
    ActionController::Base.logger = ActiveSupport::Logger.new(log)

    sign_in_as users(:one)
    get rails_blob_path(blob)

    assert_redirected_to location
    assert_includes log.string, "X-Amz-Signature=[FILTERED]"
    assert_not_includes log.string, "secret-signature"
  ensure
    ActionController::Base.logger = original_logger
    blob&.purge
  end
end

require "test_helper"
require "open3"

class ProductionHostAuthorizationTest < ActiveSupport::TestCase
  test "production rejects untrusted hosts and forwarded hosts while allowing the healthcheck" do
    requests = [
      { host: "fastretro.app", path: "/missing-page", status: 404 },
      { host: "fastretro.app", forwarded_host: "fastretro.app", path: "/missing-page", status: 404 },
      { host: "attacker.example", path: "/missing-page", status: 403 },
      { host: "subdomain.fastretro.app", path: "/missing-page", status: 403 },
      { host: "fastretro.app.attacker.example", path: "/missing-page", status: 403 },
      { host: "attacker.example", forwarded_host: "fastretro.app", path: "/missing-page", status: 403 },
      { host: "fastretro.app", forwarded_host: "attacker.example", path: "/iupjournals/index.php/esj", status: 403 },
      { host: "fastretro.app", forwarded_host: 'foo"><script>alert(document.domain)</script><x=".com', path: "/iupjournals/index.php/esj", status: 403 },
      { host: "fastretro.app", forwarded_host: "fastretro.app, attacker.example", path: "/missing-page", status: 403 },
      { host: "127.0.0.1", path: "/up", status: 200 },
      { host: "127.0.0.1", path: "/up", method: "head", status: 200 },
      { host: "127.0.0.1", path: "/up/missing-page", status: 403 }
    ]

    assert_production_responses requests
  end

  test "self hosted production uses APP_HOST as its allowed host" do
    assert_production_responses [
      { host: "retro.example.org", path: "/missing-page", status: 404 },
      { host: "retro.example.org", forwarded_host: "retro.example.org", path: "/missing-page", status: 404 },
      { host: "fastretro.app", path: "/missing-page", status: 403 }
    ], app_host: "retro.example.org"
  end

  test "static files without fingerprints expire from caches after five minutes" do
    assert_production_responses [
      { host: "fastretro.app", path: "/error.css", status: 200, cache_control: "public, max-age=300" },
      { host: "fastretro.app", path: "/404.html", status: 200, cache_control: "public, max-age=300" }
    ]
  end

  test "BASE_URL configures self hosted links and the allowed host with a nonstandard port" do
    assert_production_responses [
      { host: "retro.example.org:8443", path: "/missing-page", status: 404 },
      { host: "fastretro.app", path: "/missing-page", status: 403 }
    ], environment: { "SAAS" => "false", "BASE_URL" => "https://retro.example.org:8443" },
      configuration: { "storage" => "local", "session_url" => "https://retro.example.org:8443/session/new",
                       "mailer_url_options" => { "host" => "retro.example.org", "protocol" => "https", "port" => 8443 } }
  end

  test "self hosting can select S3 and SaaS retains its S3 storage" do
    [ { "SAAS" => "false", "ACTIVE_STORAGE_SERVICE" => "s3" }, { "SAAS" => "true" } ].each do |environment|
      assert_production_responses [], environment: environment, configuration: { "storage" => "s3" }
    end
  end

  test "Trusted Types sampling is wired into production responses and can be disabled" do
    [ [ "1", "require-trusted-types-for 'script'; report-uri /trusted_types_reports" ], [ "0", nil ] ].each do |rate, policy|
      assert_production_responses [ { host: "fastretro.app", path: "/up", status: 200, trusted_types: policy } ],
        environment: { "CSP_TRUSTED_TYPES_SAMPLE_RATE" => rate }
    end
  end

  test "production SSL options honor individual overrides and the combined disable switch" do
    [
      [ {}, true, true ],
      [ { "DISABLE_SSL" => "true", "ASSUME_SSL" => "true" }, true, false ],
      [ { "ASSUME_SSL" => "false", "FORCE_SSL" => "true" }, false, true ],
      [ { "ASSUME_SSL" => "true", "FORCE_SSL" => "false" }, true, false ],
      [ { "DISABLE_SSL" => "true" }, false, false ],
      [ { "DISABLE_SSL" => "true", "FORCE_SSL" => "true" }, false, true ]
    ].each do |environment, assume_ssl, force_ssl|
      assert_production_responses [], environment: environment,
        configuration: { "assume_ssl" => assume_ssl, "force_ssl" => force_ssl }
    end
  end

  test "production Sentry hooks redact credential paths without sending an event" do
    assert_production_responses [],
      environment: { "SENTRY_DSN" => "https://public@sentry.example.invalid/1", "SKIP_TELEMETRY" => nil },
      configuration: { "sentry_error_url" => "https://retro.example/session/transfers/[FILTERED]",
                       "sentry_transaction_url" => "https://retro.example/session/transfers/[FILTERED]",
                       "sentry_error_message" => "[FILTERED: a statement on a redacted table failed]",
                       "sentry_transaction_sql" => "SELECT * FROM magic_links WHERE code = '[FILTERED]'",
                       "sentry_breadcrumb_sql" => "SELECT * FROM magic_links WHERE code = '[FILTERED]'" }
  end

  private
    def assert_production_responses(requests, app_host: nil, environment: {}, configuration: {})
      environment = {
        "SAAS" => "false", "BASE_URL" => nil, "ACTIVE_STORAGE_SERVICE" => nil,
        "ASSUME_SSL" => nil, "FORCE_SSL" => nil,
        "RAILS_ENV" => "production", "APP_HOST" => app_host, "DISABLE_SSL" => nil,
        "SECRET_KEY_BASE_DUMMY" => "1", "SKIP_TELEMETRY" => "true", "RAILS_LOG_LEVEL" => "fatal",
        "DATABASE_URL" => "sqlite3::memory:", "CACHE_DATABASE_URL" => "sqlite3::memory:",
        "QUEUE_DATABASE_URL" => "sqlite3::memory:", "CABLE_DATABASE_URL" => "sqlite3::memory:",
        "S3_ACCESS_KEY" => "test", "S3_SECRET_KEY" => "test", "S3_REGION" => "us-east-1",
        "S3_BUCKET" => "test", "AWS_EC2_METADATA_DISABLED" => "true"
      }.merge(environment)

      script = <<~RUBY
        responses = JSON.parse(ARGV.fetch(0)).map do |request|
          client = ActionDispatch::Integration::Session.new(Rails.application)
          client.host! request.fetch("host")
          client.https!
          headers = {}
          headers["X-Forwarded-Host"] = request["forwarded_host"] if request["forwarded_host"]
          client.public_send(request.fetch("method", "get"), request.fetch("path"), headers: headers)
          { status: client.response.status, location: client.response.location, cache_control: client.response.headers["Cache-Control"], trusted_types: client.response.headers["Content-Security-Policy-Report-Only"] }
        end
        sentry_urls = {}
        if Sentry.initialized?
          { error: Sentry.configuration.before_send, transaction: Sentry.configuration.before_send_transaction }.each do |type, filter|
            event = type == :transaction ? Sentry::TransactionEvent.new(transaction: Sentry::Transaction.new(name: "request"), configuration: Sentry.configuration) : Sentry::ErrorEvent.new(configuration: Sentry.configuration)
            if type == :transaction
              event.spans = [ { op: "db.sql.query", description: "SELECT * FROM magic_links WHERE code = 'made-up-code'" } ]
            else
              event.add_exception_interface(StandardError.new(%(INSERT INTO "magic_links" VALUES ('made-up-code'))), mechanism: nil)
            end
            event.rack_env = Rack::MockRequest.env_for("https://retro.example/session/transfers/made-up-credential")
            sentry_urls["sentry_\#{type}_url"] = filter.call(event, {}).request.url
            sentry_urls["sentry_error_message"] = event.exception.values.first.value if type == :error
            sentry_urls["sentry_transaction_sql"] = event.spans.first[:description] if type == :transaction
          end
        end
        if Sentry.initialized?
          breadcrumb = Sentry::Breadcrumb.new(data: { sql: "SELECT * FROM magic_links WHERE code = 'made-up-code'" })
          sentry_urls["sentry_breadcrumb_sql"] = Sentry.configuration.before_breadcrumb.call(breadcrumb, {}).data[:sql]
        end
        puts JSON.generate(responses: responses, configuration: {
          **sentry_urls,
          assume_ssl: Rails.application.config.assume_ssl, force_ssl: Rails.application.config.force_ssl,
          storage: ActiveStorage::Blob.service.name,
          session_url: (Rails.application.routes.url_helpers.new_session_url if ENV["BASE_URL"].present?),
          mailer_url_options: ActionMailer::Base.default_url_options
        })
      RUBY

      output, errors, status = Open3.capture3(environment, RbConfig.ruby, "bin/rails", "runner", "-", requests.to_json,
        stdin_data: script, chdir: Rails.root)

      assert status.success?, "Production boot failed:\n#{output}\n#{errors}"
      result = JSON.parse(output.lines.last)
      configuration.each { |key, value| assert_equal value, result.fetch("configuration").fetch(key) }
      responses = result.fetch("responses")
      assert_equal requests.size, responses.size
      requests.zip(responses).each do |request, response|
        assert_equal request.fetch(:status), response.fetch("status"), request.inspect
        assert_nil response.fetch("location"), request.inspect
        assert_equal request[:cache_control], response.fetch("cache_control") if request.key?(:cache_control)
        if request.key?(:trusted_types)
          request[:trusted_types] ? assert_equal(request[:trusted_types], response.fetch("trusted_types")) : assert_nil(response.fetch("trusted_types"))
        end
      end
    end
end

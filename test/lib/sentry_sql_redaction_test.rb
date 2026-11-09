require "test_helper"

class SentrySqlRedactionTest < ActiveSupport::TestCase
  test "error events scrub database credentials while retaining unrelated errors and request redaction" do
    configuration = Sentry::Configuration.new
    SentrySqlRedaction.install(configuration)
    event = Sentry::ErrorEvent.new(configuration: configuration)
    event.add_exception_interface(StandardError.new("INSERT INTO \"identity_transfers\" VALUES ('made-up-secret')"), mechanism: nil)
    event.rack_env = Rack::MockRequest.env_for("https://retro.example/session/transfers/made-up-transfer")
    filtered = configuration.before_send.call(event, {})

    assert_not_includes filtered.to_h.to_json, "made-up-secret"
    assert_not_includes filtered.to_h.to_json, "made-up-transfer"
    assert_includes filtered.to_h.to_json, "/session/transfers/[FILTERED]"

    event = Sentry::ErrorEvent.new(configuration: configuration)
    event.add_exception_interface(StandardError.new("No route matches /my/webhooks"), mechanism: nil)
    assert_includes configuration.before_send.call(event, {}).to_h.to_json, "No route matches /my/webhooks"
  end

  test "SQL breadcrumb and transaction backstops redact literals while preserving other diagnostics" do
    configuration = Sentry::Configuration.new
    SentrySqlRedaction.install(configuration)
    sql = "SELECT * FROM magic_links WHERE code = 'made-up-secret'"
    breadcrumb = Sentry::Breadcrumb.new(category: "sql.active_record", data: { sql: sql })
    assert_not_includes configuration.before_breadcrumb.call(breadcrumb, {}).to_h.to_json, "made-up-secret"
    breadcrumb = Sentry::Breadcrumb.new(category: "navigation", data: { destination: "/retros" })
    assert_equal "/retros", configuration.before_breadcrumb.call(breadcrumb, {}).data[:destination]

    event = Sentry::TransactionEvent.new(transaction: Sentry::Transaction.new(name: "request"), configuration: configuration)
    event.spans = [ { op: "db.sql.query", description: sql }, { op: "http.client", description: "GET /retros" } ]
    filtered = configuration.before_send_transaction.call(event, {})
    assert_not_includes filtered.to_h.to_json, "made-up-secret"
    assert_equal "GET /retros", filtered.spans.last[:description]
  end
end

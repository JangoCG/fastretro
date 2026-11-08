require "test_helper"

class ActiveRecordSqlRedactionTest < ActiveSupport::TestCase
  test "SQL consumers see no credential binds while database values remain usable" do
    log, seen = capture do
      link = identities(:admin).magic_links.create!(code: "ZQ7XW3")
      assert_equal "ZQ7XW3", link.reload.code
      ActiveRecord::Base.cache do
        2.times { assert_equal link.id, MagicLink.find_by!(code: "ZQ7XW3").id }
      end
      transfer = identities(:admin).transfers.create!(token: "madeUpTransferToken00000")
      assert_equal identities(:admin), Identity.find_by_transfer_id(transfer.token)
      assert Account::JoinCode.find_by(code: accounts(:one).join_code.code)
    end

    assert_match(/magic_links/, log)
    [ "ZQ7XW3", "madeUpTransferToken00000", accounts(:one).join_code.code ].each do |secret|
      assert_not_includes log, secret
      assert_not_includes seen.inspect, secret
    end
    assert seen.any? { |payload| payload[:sql].include?("magic_links") }
    assert seen.any? { |payload| payload[:cached] }
    credential_queries = seen.select { |payload| payload[:sql].match?(/magic_links|identity_transfers|account_join_codes/) }
    assert credential_queries.all? { |payload| payload[:binds].empty? && payload[:type_casted_binds].empty? }
  end

  test "bulk SQL literals are redacted while ordinary table diagnostics remain readable" do
    token = "madeUpTransferToken00000\\"
    log, seen = capture do
      Identity::Transfer.insert_all!([ { identity_id: identities(:admin).id, token: token } ])
      assert_equal token, Identity::Transfer.find_by!(token: token).token
      assert_equal identities(:admin).id, Identity.where("id = #{identities(:admin).id}").pick(:id)
    end

    assert_match(/INSERT INTO ["`]identity_transfers/, log)
    assert_not_includes log, token
    assert_not_includes seen.inspect, token
    assert seen.any? { |payload| payload[:sql].include?("id = #{identities(:admin).id}") }
    identity_lookup = seen.find { |payload| payload[:sql].include?('"identities"."id" = ?') }
    assert_includes identity_lookup[:type_casted_binds], identities(:admin).id
  end

  test "invalid SQL exposes no secret in the error or its notification" do
    log, seen = capture do
      error = assert_raises ActiveRecord::StatementInvalid do
        MagicLink.connection.select_all("SELECT * FROM magic_links WHERE code = 'ZQ7XW3' INVALID")
      end
      [ error, error.cause ].compact.each do |exception|
        [ exception.message, exception.to_s, exception.detailed_message, exception.full_message, exception.inspect ].each do |text|
          assert_not_includes text, "ZQ7XW3"
        end
      end
    end
    assert_not_includes log, "ZQ7XW3"
    assert_not_includes seen.inspect, "ZQ7XW3"
  end

  test "explain can still execute an unredacted query" do
    assert_match(/EXPLAIN/i, MagicLink.where("code IN ('ZQ7XW3')").explain.inspect)
    _log, seen = capture { MagicLink.where("code IN ('ZQ7XW3')").to_a }
    assert_not_includes seen.inspect, "ZQ7XW3"
  end

  test "credential filtering preserves uniqueness error classification" do
    identities(:admin).magic_links.create!(code: "ZQ7XW3")
    _log, seen = capture do
      error = assert_raises ActiveRecord::RecordNotUnique do
        identities(:admin).magic_links.new(code: "ZQ7XW3", expires_at: 1.minute.from_now).save!(validate: false)
      end
      assert_not_includes error.message, "ZQ7XW3"
      assert_not_includes error.cause.message, "ZQ7XW3"
    end
    assert_not_includes seen.inspect, "ZQ7XW3"
  end

  test "readonly errors redact credential SQL while unrelated SQL errors retain diagnostics" do
    error = assert_raises ActiveRecord::ReadOnlyError do
      ActiveRecord::Base.while_preventing_writes do
        MagicLink.where("code = 'ZQ7XW3'").delete_all
      end
    end
    assert_not_includes error.message, "ZQ7XW3"
    error = assert_raises ActiveRecord::StatementInvalid do
      Identity.connection.select_all("SELECT * FROM identities WHERE email_address = 'diagnostic-value' INVALID")
    end
    assert_includes error.message, "diagnostic-value"
  end

  test "the SQL hook leaves unrelated notification payloads unchanged" do
    sql = "SELECT * FROM magic_links WHERE code = 'ZQ7XW3'"
    observed = nil
    listener = ActiveSupport::Notifications.subscribe("external.query") { |event| observed = event.payload[:sql] }
    ActiveSupport::Notifications.instrument("external.query", sql: sql)
    assert_equal sql, observed
  ensure
    ActiveSupport::Notifications.unsubscribe(listener) if listener
  end

  private
    def capture
      log, seen = StringIO.new, []
      original_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = ActiveSupport::Logger.new(log)
      listeners = [
        ActiveSupport::Notifications.subscribe("sql.active_record") { |event| seen << diagnostic_payload(event.payload) },
        ActiveSupport::Notifications.subscribe("sql.active_record") { |_name, _start, _finish, _id, payload| seen << diagnostic_payload(payload) },
        ActiveSupport::Notifications.subscribe(/sql\.active_record/) { |_name, _start, _finish, _id, payload| seen << diagnostic_payload(payload) }
      ]
      yield
      [ log.string, seen ]
    ensure
      listeners&.each { |listener| ActiveSupport::Notifications.unsubscribe(listener) }
      ActiveRecord::Base.logger = original_logger
    end

    def diagnostic_payload(payload)
      binds = payload[:type_casted_binds]
      { sql: payload[:sql], binds: Array(payload[:binds]).map { |bind| bind.try(:value_before_type_cast) || bind },
        type_casted_binds: binds.respond_to?(:call) ? binds.call : binds, exception: payload[:exception], cached: payload[:cached] }
    end
end

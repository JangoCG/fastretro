require "test_helper"

class CredentialPathsTest < ActionDispatch::IntegrationTest
  test "credentials are filtered in request logs including unmatched suffixes" do
    secret = "made-up-secret-credential"
    paths = [
      join_path(secret), retro_invite_path(secret, retros(:one)),
      user_email_address_confirmation_path(users(:one), secret),
      session_transfer_path(secret, script_name: nil)
    ]
    paths.each do |path|
      [ path, "#{path}/xmlrpc.php" ].each do |request_path|
        log = capture_request_log do
          begin
            get request_path
          rescue ActionController::RoutingError
          end
        end
        assert_includes log, "[FILTERED]", request_path
        assert_not_includes log, secret, request_path
      end
    end
  end

  test "Sentry error and transaction events filter URLs referrers and path transaction names" do
    path = session_transfer_path("made-up-transfer", script_name: nil)
    [ Sentry::ErrorEvent.new(configuration: Sentry::Configuration.new), Sentry::TransactionEvent.new(transaction: Sentry::Transaction.new(name: path), configuration: Sentry::Configuration.new) ].each do |event|
      event.rack_env = Rack::MockRequest.env_for("https://retro.example#{path}", "HTTP_REFERER" => "https://retro.example#{join_path('made-up-code')}")
      event.transaction = path
      filtered = SentrySqlRedaction.public_send(event.is_a?(Sentry::TransactionEvent) ? :before_send_transaction : :before_send, event, {})
      serialized = filtered.to_h.to_json
      assert_not_includes serialized, "made-up-transfer"
      assert_not_includes serialized, "made-up-code"
      assert_includes serialized, "/session/transfers/[FILTERED]"
      assert_includes serialized, "/join/[FILTERED]"
    end
  end

  private
    def capture_request_log
      log = StringIO.new
      original_rails_logger, original_controller_logger = Rails.logger, ActionController::Base.logger
      Rails.logger = ActionController::Base.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(log))
      yield
      log.string
    ensure
      Rails.logger, ActionController::Base.logger = original_rails_logger, original_controller_logger
    end
end

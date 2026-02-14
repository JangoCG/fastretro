# frozen_string_literal: true

module Middleware
  class OtelLogTagsMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless tracing_enabled?

      span_context = OpenTelemetry::Trace.current_span.context
      return @app.call(env) unless span_context.valid?

      Rails.logger.tagged("trace_id=#{span_context.hex_trace_id}", "span_id=#{span_context.hex_span_id}") do
        @app.call(env)
      end
    end

    private
      def tracing_enabled?
        defined?(OpenTelemetry::Trace)
      end
  end
end

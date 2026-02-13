# frozen_string_literal: true

module Middleware
  class OtelLogTagsMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      span_context = OpenTelemetry::Trace.current_span.context
      return @app.call(env) unless span_context.valid?

      Rails.logger.tagged("trace_id=#{span_context.hex_trace_id}", "span_id=#{span_context.hex_span_id}") do
        @app.call(env)
      end
    rescue NameError
      @app.call(env)
    end
  end
end

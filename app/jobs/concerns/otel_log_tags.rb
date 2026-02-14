# frozen_string_literal: true

module OtelLogTags
  extend ActiveSupport::Concern

  included do
    around_perform :with_otel_log_tags
  end

  private
    def with_otel_log_tags
      return yield unless tracing_enabled?

      span_context = OpenTelemetry::Trace.current_span.context

      if span_context.valid?
        Rails.logger.tagged("trace_id=#{span_context.hex_trace_id}", "span_id=#{span_context.hex_span_id}") do
          yield
        end
      else
        yield
      end
    end

    def tracing_enabled?
      defined?(OpenTelemetry::Trace)
    end
end

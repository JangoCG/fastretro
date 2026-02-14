# frozen_string_literal: true

# OpenTelemetry traces configuration.
#
# Traces are enabled only when OTEL_EXPORTER_OTLP_ENDPOINT is set.
if ENV["OTEL_EXPORTER_OTLP_ENDPOINT"].present? && ENV["SKIP_TELEMETRY"].blank? && !Rails.env.test?
  require "opentelemetry/sdk"
  require "opentelemetry/exporter/otlp"
  require "opentelemetry/instrumentation/rails"
  require "opentelemetry/instrumentation/action_pack"
  require "opentelemetry/instrumentation/rack"
  require "opentelemetry/instrumentation/active_record"
  require "opentelemetry/instrumentation/active_job"
  require "opentelemetry/instrumentation/net/http"

  default_service_name = [ "fastretro", ENV["KAMAL_DESTINATION"].presence || Rails.env ].join("-")
  sample_ratio = begin
    ratio = Float(ENV.fetch("OTEL_TRACE_SAMPLE_RATIO", "0.2"))
    [[ ratio, 0.0 ].max, 1.0].min
  rescue ArgumentError, TypeError
    0.2
  end

  if Rails.env.production?
    ENV["OTEL_TRACES_SAMPLER"] ||= "parentbased_traceidratio"
    ENV["OTEL_TRACES_SAMPLER_ARG"] ||= sample_ratio.to_s
  else
    ENV["OTEL_TRACES_SAMPLER"] ||= "parentbased_always_on"
  end

  OpenTelemetry::SDK.configure do |config|
    config.service_name = ENV.fetch("OTEL_SERVICE_NAME", default_service_name)
    config.use "OpenTelemetry::Instrumentation::Rails"
    config.use "OpenTelemetry::Instrumentation::ActionPack"
    config.use "OpenTelemetry::Instrumentation::Rack"
    config.use "OpenTelemetry::Instrumentation::ActiveRecord"
    config.use "OpenTelemetry::Instrumentation::ActiveJob"
    config.use "OpenTelemetry::Instrumentation::Net::HTTP"
  end
end

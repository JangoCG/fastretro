# frozen_string_literal: true

return unless FastRetro.saas?

require "yabeda"
require "yabeda/rails"
require "yabeda/actioncable"
require "yabeda/activejob"
require "yabeda/gc"
require "yabeda/http_requests"
require "yabeda/prometheus/mmap"
require "prometheus/client/support/puma"

Prometheus::Client.configuration.logger = Rails.logger
Prometheus::Client.configuration.pid_provider = Prometheus::Client::Support::Puma.method(:worker_pid_provider)

Yabeda::Rails.config.controller_name_case = :camel
Yabeda::Rails.config.ignore_actions = %w[
  Rails::HealthController#show
]

Yabeda::ActiveJob.install!

require "yabeda/solid_queue"
Yabeda::SolidQueue.install!

Yabeda::ActionCable.configure do |config|
  config.channel_class_name = "ActionCable::Channel::Base"
end

require "yabeda/fast_retro"
Yabeda::FastRetro.install!

SolidQueue.on_start do
  Yabeda::Prometheus::Exporter.start_metrics_server!
end

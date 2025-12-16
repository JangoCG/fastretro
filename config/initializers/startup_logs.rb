# frozen_string_literal: true

# Logs application mode configuration on startup.
#
# SaaS Mode - enables usage limits, Stripe subscriptions, and payment integration:
#   Localhost:   rake saas:enable / rake saas:disable / rake saas:status
#   Deployment:  SAAS=true
#
# Multi-Tenant Mode - enables URL-based multi-tenancy (e.g., /1234567/retros):
#   Localhost:   rake multi_tenant:enable / rake multi_tenant:disable / rake multi_tenant:status
#   Deployment:  MULTI_TENANT=true
Rails.application.configure do
  config.after_initialize do
    next unless Rails.env.development? || ENV["LOG_STARTUP"].present?

    puts ""
    puts "┌─────────────────────────────────────────┐"
    puts "│         FastRetro Configuration         │"
    puts "├─────────────────────────────────────────┤"
    puts "│  SaaS Mode:         #{FastRetro.saas? ? '✓ ENABLED ' : '✗ disabled'}          │"
    puts "│  Multi-Tenant Mode: #{Account.multi_tenant? ? '✓ ENABLED ' : '✗ disabled'}          │"
    puts "└─────────────────────────────────────────┘"
    puts ""
  end
end

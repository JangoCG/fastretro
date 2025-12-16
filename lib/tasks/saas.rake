# frozen_string_literal: true

namespace :saas do
  desc "Enable SaaS mode (creates tmp/saas.txt)"
  task enable: :environment do
    FileUtils.touch(Rails.root.join("tmp/saas.txt"))
    puts "SaaS mode enabled"
    puts "Restart your server for changes to take effect"
  end

  desc "Disable SaaS mode (removes tmp/saas.txt)"
  task disable: :environment do
    FileUtils.rm_f(Rails.root.join("tmp/saas.txt"))
    puts "SaaS mode disabled"
    puts "Restart your server for changes to take effect"
  end

  desc "Check current SaaS mode status"
  task status: :environment do
    require_relative "../fastretro"

    if FastRetro.saas?
      puts "SaaS mode: ENABLED"
      puts "  - Usage limits are enforced"
      puts "  - Stripe integration is active"
      puts "  - Subscription page is visible"
    else
      puts "SaaS mode: DISABLED"
      puts "  - No usage limits"
      puts "  - Self-hosted mode"
    end
  end
end

# frozen_string_literal: true

namespace :multi_tenant do
  desc "Enable multi-tenant mode (creates tmp/multi_tenant.txt)"
  task enable: :environment do
    FileUtils.touch(Rails.root.join("tmp/multi_tenant.txt"))
    Account.reset_multi_tenant!
    puts "Multi-tenant mode enabled"
    puts "Restart your server for changes to take effect"
  end

  desc "Disable multi-tenant mode (removes tmp/multi_tenant.txt)"
  task disable: :environment do
    FileUtils.rm_f(Rails.root.join("tmp/multi_tenant.txt"))
    Account.reset_multi_tenant!
    puts "Multi-tenant mode disabled"
    puts "Restart your server for changes to take effect"
  end

  desc "Check current multi-tenant mode status"
  task status: :environment do
    if Account.multi_tenant?
      puts "Multi-tenant mode: ENABLED"
      puts "  - Multiple accounts supported"
      puts "  - URL-based account routing active"
    else
      puts "Multi-tenant mode: DISABLED"
      puts "  - Single account mode"
    end
  end
end

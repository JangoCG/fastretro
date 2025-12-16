# frozen_string_literal: true

namespace :demo do
  desc "Reset database and seed with demo data"
  task setup: :environment do
    puts "Resetting database..."
    Rake::Task["db:reset"].invoke

    puts ""
    puts "Loading demo data..."
    load Rails.root.join("db/seeds/demo.rb")
  end

  desc "Seed demo data without reset (adds to existing data)"
  task seed: :environment do
    load Rails.root.join("db/seeds/demo.rb")
  end
end

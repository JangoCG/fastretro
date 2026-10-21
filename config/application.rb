require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "../lib/action_pack/railtie"
require_relative "../lib/fastretro"
require_relative "../lib/fastretro/cell"

module Fastretro
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    #
    # rails_ext/ is excluded because it contains patches to Rails internals that
    # don't follow autoload naming conventions. These files are manually required
    # via config/initializers/extensions.rb instead.
    # FastRetro uses a different spelling from the application's Fastretro namespace.
    # Its configuration modules are required explicitly above.
    config.autoload_lib(ignore: %w[assets tasks rails_ext yabeda middleware fastretro])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.available_locales = [ :en, :de ]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true

    initializer "fastretro.hotcell", before: "active_storage.configs" do |app|
      FastRetro::Cell.register!
      HotCell.diagnostics_controller_parent = "AdminController"
      app.config.active_storage.merge! FastRetro::Cell.active_storage_configuration
    end

    config.after_initialize do
      HotCell.describe_cells
    end
  end
end

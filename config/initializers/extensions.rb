# frozen_string_literal: true

# Loads all Rails framework extensions from lib/rails_ext/.
#
# Files in lib/rails_ext/ contain patches or extensions to Rails internals
# (e.g., ActionMailer::MailDeliveryJob). These files are excluded from Rails
# autoloading because:
#
#   1. They don't follow the standard class/module naming conventions
#   2. They need to load at a specific time during Rails initialization
#   3. They patch existing Rails classes rather than define new ones
#
# This initializer manually requires each file, ensuring they load after Rails
# is fully initialized but before the application starts serving requests.
#
# @see config/application.rb - where rails_ext is excluded from autoload
# @see lib/rails_ext/action_mailer_mail_delivery_job.rb
#
Dir["#{Rails.root}/lib/rails_ext/*"].each { |path| require "rails_ext/#{File.basename(path)}" }

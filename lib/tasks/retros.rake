namespace :retros do
  namespace :retention_reminders do
    desc "Show completed retros eligible for retention reminders"
    task dry_run: :environment do
      RetentionReminderBackfill.new(dry_run: true).run
    end

    desc "Enqueue retention reminders for existing completed retros"
    task enqueue: :environment do
      RetentionReminderBackfill.new(dry_run: false, limit: ENV["LIMIT"]).run
    end
  end
end

class RetentionReminderBackfill
  def initialize(dry_run:, limit: nil, output: $stdout)
    @dry_run = dry_run
    @limit = limit.presence&.to_i
    @output = output
  end

  def run
    output.puts "Eligible retros: #{scope.count}"
    output.puts "Mode: #{dry_run? ? "dry-run" : "enqueue"}"
    output.puts "Limit: #{limit}" if limit

    return if dry_run?

    enqueued = 0
    scope.find_each do |retro|
      Current.set(account: retro.account) do
        Retro::RetentionReminderJob.perform_later(retro)
      end
      enqueued += 1
    end

    output.puts "Enqueued reminders: #{enqueued}"
  end

  private
    attr_reader :limit, :output

    def dry_run?
      @dry_run
    end

    def scope
      scoped = Retro.due_for_retention_reminder.includes(account: { owner_user: :identity })
      scoped = scoped.limit(limit) if limit
      scoped
    end
end

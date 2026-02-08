unless Rails.env.production?
  require "prosopite/middleware/rack"
  Rails.configuration.middleware.use(Prosopite::Middleware::Rack)

  # Prosopite assumes pg_query for non-MySQL databases, but SQLite's
  # ? placeholders aren't valid PostgreSQL syntax. The regex-based
  # fingerprinter works fine for any SQL dialect.
  Prosopite.singleton_class.prepend(Module.new do
    def fingerprint(query)
      mysql_fingerprint(query)
    end
  end)
end

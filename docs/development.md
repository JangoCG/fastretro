## Development

### Setting up

First, get everything installed and configured with:

```sh
bin/setup
bin/setup --reset # Reset the database and seed it
```

And then run the development server:

```sh
bin/dev
```

You'll be able to access the app in development at http://localhost:3000.

### Running tests

For fast feedback loops, unit tests can be run with:

```sh
bin/rails test
```

System tests (Capybara) can be run with:

```sh
bin/rails test:system
```

The full continuous integration suite can be run with:

```sh
bin/ci
```

The CI pipeline runs: rubocop, bundler-audit, importmap audit, brakeman, unit tests, system tests, and seed tests.

### Database configuration

Fast Retro uses SQLite by default.

### Outbound Emails

You can view email previews at http://localhost:3000/rails/mailers.

You can enable or disable [`letter_opener`](https://github.com/ryanb/letter_opener) to open sent emails automatically with:

```sh
bin/rails dev:email
```

Under the hood, this will create or remove `tmp/email-dev.txt`.

### Multi-Tenant Mode

Multi-tenant mode is **disabled by default** (single account mode). When enabled, it adds URL-based multi-tenancy where each account has a unique ID that prefixes all URLs (e.g., `/1234567/retros`).

```sh
rake multi_tenant:enable   # Enable multi-tenant mode
rake multi_tenant:disable  # Disable multi-tenant mode
rake multi_tenant:status   # Check current status
```

In production, set `MULTI_TENANT=true` as an environment variable.

See [Multi-Tenant Architecture documentation](multi-tenant-magic-link-auth.md) for more details.

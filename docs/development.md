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

### Linting

To run RuboCop and auto-fix all files:

```sh
bin/rubocop -A
```

### Running tests

For fast feedback loops, unit tests can be run with:

```sh
bin/rails test
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

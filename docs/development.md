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

### Seeding the Database

Fast Retro includes demo data for development and screenshots.

```sh
bin/rails runner db/seeds/demo.rb
```
Login credentials:
- **Owner**: sarah@acmecorp.com
- **Admin**: marcus@acmecorp.com
- **Member**: emily@acmecorp.com


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

### Image Optimization

To optimize page load times, images should be converted to WebP format, which provides significant file size reductions while maintaining quality.

#### Prerequisites

Install the WebP tools via Homebrew:

```sh
brew install webp
```

#### Converting Images to WebP

For individual images with high quality (recommended for hero/landing page images):

```sh
cwebp -q 85 input-image.png -o output-image.webp
```

For batch conversion of all PNG/JPG/JPEG images in a directory (with lower quality for thumbnails/icons):

```sh
find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -exec cwebp -q 10 {} -o {}.webp \;
```

#### Quality Settings

The `-q` flag controls the quality (0-100):
- **85-95**: High quality for hero images, screenshots, and detailed graphics
- **70-80**: Good balance for general content images
- **50-60**: Acceptable for thumbnails and non-critical images
- **10-30**: Very compressed, suitable for background textures or when file size is critical

#### After Conversion

1. Update your view files to reference the `.webp` versions:
   ```erb
   <%= image_tag "hero-image.webp", class: "..." %>
   ```

### Billing Waivers (Comping Accounts)

For testing or providing free unlimited access to specific accounts (e.g., beta testers, partners), you can "comp" an account to bypass billing limits without requiring a Stripe subscription.

#### Comping an Account

To grant unlimited access to an account on production:

```ruby
# Open Rails console on production
bin/rails console -e production

# Find the account (by ID, name, or owner email)
account = Account.find(123)
# or
account = Account.find_by(name: "Company Name")
# or via user email
account = Identity.find_by(email_address: "user@example.com").accounts.first

# Comp the account (grants unlimited feedbacks)
account.comp

# Verify it worked
account.comped?  # => true
account.plan     # => Plan.paid (even without Stripe subscription)
```

#### Removing a Comp

To remove unlimited access and return the account to normal billing:

```ruby
account.uncomp

# Verify
account.comped?  # => false
account.plan     # => Plan.free (or Plan.paid if they have active subscription)
```

#### How It Works

- A comped account gets a `billing_waiver` record
- The waiver acts like a paid subscription without Stripe
- Comped accounts bypass all feedback limits
- The subscription panel won't show for comped accounts (only admins/owners see billing UI for regular accounts)
- Comping is idempotent - calling `comp` multiple times won't create duplicates

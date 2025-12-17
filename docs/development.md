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

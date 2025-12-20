## Deploying with Docker

We provide pre-built Docker images that can be used to run Fast Retro on your own server.

If you don't need to change the source code, and just want the out-of-the-box Fast Retro experience, this can be a great way to get started.

You'll find the latest version of Fast Retro's Docker image at `<PUBLIC_IMAGE_WILL_BE_PROVIDED_SOON>`.
To run it you'll need three things: a machine that runs Docker; a mounted volume (so that your database is stored somewhere that is kept around between restarts); and some environment variables for configuration.

### Mounting a storage volume

The standard Fast Retro setup keeps all of its storage inside the path `/rails/storage`.
By default Docker containers don't persist storage between runs, so you'll want to mount a persistent volume into that location.

The simplest way to do this is with the `--volume` flag with `docker run`. For example:

```sh
docker run --volume fastretro:/rails/storage <PUBLIC_IMAGE_WILL_BE_PROVIDED_SOON>
```

That will create a named volume (called `fastretro`) and mount it into the correct path.
Docker will manage where that volume is actually stored on your server.

You can also specify the data location yourself, mount a network drive, and more.
Check the Docker documentation to find out more about what's available.

### Configuring with environment variables

To configure your Fast Retro installation, you can use environment variables.
Fast Retro has several of them.
Many of these are optional, but at a minimum you'll want to configure your secret key, your SSL domain, and your SMTP email settings.

#### Secret Key Base

Various features inside Fast Retro rely on cryptography to work (such as secure links).
To set this up, you need to provide a secret value that will be used as the basis of those secrets.
This value can be anything, but it should be unguessable, and specific to your instance.

You can use any long random string for this, or you can have the Fast Retro codebase generate one for you by running:

```sh
bin/rails secret
```

Once you have one, set it in the `SECRET_KEY_BASE` environment variable:

```sh
docker run --environment SECRET_KEY_BASE=abcdefabcdef ...
```

#### SSL

If you want the Fast Retro container to handle its own SSL automatically, you just need to specify the domain name that you're running it on.
You can do that with the `TLS_DOMAIN` environment variable.
Note that if you're using SSL, you'll want to allow traffic on ports 80 and 443.
So if you were running on `retro.example.com` you could enable SSL like this:

```sh
docker run --publish 80:80 --publish 443:443 --environment TLS_DOMAIN=retro.example.com ...
```

If you are terminating SSL in some other proxy in front of Fast Retro, then you don't need to set `TLS_DOMAIN`, and can just publish port 80:

```sh
docker run --publish 80:80 ...
```

If you aren't using SSL at all (for example, if you want to run it locally on your laptop) then you should specify `DISABLE_SSL=true` instead:

```sh
docker run --publish 80:80 --environment DISABLE_SSL=true ...
```

#### SMTP Email

Fast Retro needs to be able to send email for its magic link sign in flow.
The easiest way to set this up is to use a 3rd-party email provider (such as AWS SES, Postmark, Sendgrid, and so on).
You can then plug all your SMTP settings from that provider into Fast Retro via the following environment variables:

- `MAILER_FROM_ADDRESS` - the "from" address that Fast Retro should use to send email
- `SMTP_ADDRESS` - the address of the SMTP server you'll send through
- `SMTP_PORT` - the port number (defaults to 465 when `SMTP_TLS` is set, 587 otherwise)
- `SMTP_USERNAME`/`SMTP_PASSWORD` - the credentials for logging in to the SMTP server

Less commonly, you might also need to set some of the following:

- `SMTP_TLS` - set to `true` only for servers requiring implicit TLS (SMTPS on port 465); STARTTLS is used automatically by default so most servers don't need this
- `SMTP_DOMAIN` - the domain name advertised to the server when connecting
- `SMTP_AUTHENTICATION` - if you need an authentication method other than the default `plain` (e.g., `login` for AWS SES)
- `SMTP_SSL_VERIFY_MODE` - set to `none` to skip certificate verification (for self-signed certs)

You can find out more about all these settings in the [Rails Action Mailer documentation](https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).

##### Example: AWS SES

If you're using AWS SES, your configuration would look like this:

```sh
SMTP_ADDRESS=email-smtp.eu-central-1.amazonaws.com
SMTP_USERNAME=<your-ses-smtp-username>
SMTP_PASSWORD=<your-ses-smtp-password>
SMTP_AUTHENTICATION=login
MAILER_FROM_ADDRESS=support@yourdomain.com
```

**Important:** AWS SES SMTP credentials are different from your IAM access keys. You need to generate them separately in the AWS SES Console under "SMTP Settings" > "Create SMTP Credentials".

#### Multi-tenant mode

By default, when you run the Fast Retro Docker image you'll be limited to creating a single account (although that account can have as many users as you like).
This is for convenience: typically when you self-host you'll be running a single account, so in this mode new account signups are automatically disabled as soon as you've created your first account.

If you do want to allow multiple accounts to be created in your instance, set `MULTI_TENANT=true`.

#### Background jobs

Fast Retro uses Solid Queue for background job processing. By default, jobs run in the same process as the web server. You can control this with:

- `SOLID_QUEUE_IN_PUMA` - set to `true` to run background jobs in the app container (recommended for simple deployments)

## Example

Here's an example of a `docker-compose.yml` that you could use to run Fast Retro via `docker compose up`:

```yaml
services:
  web:
    image: <PUBLIC_IMAGE_WILL_BE_PROVIDED_SOON>
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    environment:
      - SECRET_KEY_BASE=your-secret-key-base
      - TLS_DOMAIN=retro.example.com
      - MAILER_FROM_ADDRESS=retro@example.com
      - SMTP_ADDRESS=email-smtp.eu-central-1.amazonaws.com
      - SMTP_AUTHENTICATION=login
      - SMTP_USERNAME=your-smtp-username
      - SMTP_PASSWORD=your-smtp-password
      - SOLID_QUEUE_IN_PUMA=true
    volumes:
      - fastretro:/rails/storage

volumes:
  fastretro:
```

Replace the placeholder values with your actual configuration before running.

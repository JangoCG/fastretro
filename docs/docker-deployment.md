# Deploying with Docker
WIP

#### Multi-tenant mode

By default, when you run the Fast Retro Docker image you'll be limited to creating a single account (although that account can have as many users as you like).
This is for convenience: typically when you self-host you'll be running a single account, so in this mode new account signups are automatically disabled as soon as you've created your first account.

If you do want to allow multiple accounts to be created in your instance, set `MULTI_TENANT=true`

#### SMTP Email

Fast Retro needs to be able to send email for its magic link sign up/sign in flow.
The easiest way to set this up is to use a 3rd-party email provider (such as AWS SES, Postmark, Sendgrid, and so on).
You can then plug all your SMTP settings from that provider into Fast Retro via the following environment variables:

- `MAILER_FROM_ADDRESS` - the "from" address that Fast Retro should use to send email (e.g. `support@fastretro.com`)
- `SMTP_ADDRESS` - the address of the SMTP server you'll send through
- `SMTP_PORT` - the port number (defaults to 465 when `SMTP_TLS` is set, 587 otherwise)
- `SMTP_USERNAME`/`SMTP_PASSWORD` - the credentials for logging in to the SMTP server

Less commonly, you might also need to set some of the following:

- `SMTP_TLS` - set to `true` only for servers requiring implicit TLS (SMTPS on port 465); STARTTLS is used automatically by default so most servers don't need this
- `SMTP_DOMAIN` - the domain name advertised to the server when connecting
- `SMTP_AUTHENTICATION` - if you need an authentication method other than the default `plain` (e.g. `login` for AWS SES)
- `SMTP_SSL_VERIFY_MODE` - set to `none` to skip certificate verification (for self-signed certs)

You can find out more about all these settings in the [Rails Action Mailer documentation](https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).

##### Example: AWS SES

If you're using AWS SES, your configuration would look like this:

```sh
SMTP_ADDRESS=email-smtp.eu-central-1.amazonaws.com
SMTP_USERNAME=<your-ses-smtp-username>
SMTP_PASSWORD=<your-ses-smtp-password>
SMTP_AUTHENTICATION=login
MAILER_FROM_ADDRESS=support@fastretro.app
```

**Important:** AWS SES SMTP credentials are different from your IAM access keys. You need to generate them separately in the AWS SES Console under "SMTP Settings" → "Create SMTP Credentials".

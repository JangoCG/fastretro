## Deploying Fast Retro with Kamal

If you'd like to run Fast Retro on your own server while having the freedom to easily make changes to its code, we recommend deploying it with [Kamal](https://kamal-deploy.org/).
Kamal makes it easy to set up a bare server, copy the application to it, and manage the configuration settings that it uses.

This repo contains a starter deployment file that you can modify for your own specific use. That file lives at [config/deploy.yml](../config/deploy.yml), which is the default place where Kamal will look for it.

The steps to configure your very own Fast Retro are:

1. Fork the repo
2. Initialize Kamal by running `kamal init`. This command generates the `.kamal` directory along with the required configuration files, including `.kamal/secrets`.
3. Edit a few things in `config/deploy.yml` and `.kamal/secrets`
4. Run `kamal setup` to do your first deploy.

We'll go through each of these in turn.

### Fork the repo

To make it easy to customise Fast Retro's settings for your own instance, you should start by creating your own GitHub fork of the repo.
That allows you to commit your changes, and track them over time.
You can always re-sync your fork to pick up new changes from the main repo over time.

Once you've got your fork ready, run `bin/setup` from within it, to make sure everything is installed.

### Editing the configuration

The `config/deploy.yml` has been mostly set up for you, but you'll need to fill out some sections that are specific to your instance.
To get started, the parts you need to change are all in the deployment configuration.
We've added comments to that file to highlight what each setting needs to be, but the main ones are:

#### Server Configuration

- `servers/web`: Enter the IP address or hostname of the server you're deploying to. This should be an address that you can access via `ssh`.
- `ssh/user`: If you access your server as `root` you can leave this alone; if you use a different user, set it here.

#### SSL and Domain

- `proxy/ssl`: Set to `true` to enable automatic SSL certificates via Let's Encrypt.
- `proxy/host`: Set this to your domain name (e.g., `retro.yourdomain.com`).

If you're using Cloudflare, set encryption mode in SSL/TLS settings to "Full" to enable CF-to-app encryption.


#### Environment Variables

Clear (non-secret) variables to configure:

- `SMTP_ADDRESS`: The address of your SMTP server. For AWS SES, use `email-smtp.<region>.amazonaws.com`.
- `SMTP_AUTHENTICATION`: Authentication method for SMTP (typically `login` or `plain`).
- `MAILER_FROM_ADDRESS`: The email address that Fast Retro will send emails from. Should be a verified address in your email provider.
- `MULTI_TENANT`: Set to `true` to allow multiple accounts to sign up (default allows single account only).
- `SOLID_QUEUE_IN_PUMA`: Set to `true` to run background jobs in the app container.

### Setting up secrets

Fast Retro requires several environment variables containing secrets.
The simplest way to manage these is to put them in a file called `.kamal/secrets`.
Because this file contains secret credentials, it's important that you **DON'T CHECK THIS FILE INTO YOUR REPO!** You can add the filename to `.gitignore` to ensure you don't commit this file accidentally.

If you use a password manager like 1Password, you can also opt to keep your secrets there instead.
Refer to the [Kamal documentation](https://kamal-deploy.org/docs/configuration/environment-variables/#secrets) for more information about how to do that.

To store your secrets, create the file `.kamal/secrets` and enter the following:

```ini
# Rails secrets
SECRET_KEY_BASE=your-secret-key-base
RAILS_MASTER_KEY=your-master-key

# SMTP credentials (e.g., AWS SES)
SMTP_USERNAME=your-smtp-username
SMTP_PASSWORD=your-smtp-password
```

The values you enter here will be specific to you, and you can get or create them as follows:

- `SECRET_KEY_BASE`: A long, random secret. Run `bin/rails secret` to create a suitable value.
- `RAILS_MASTER_KEY`: Found in `config/master.key` (or create one with `bin/rails credentials:edit`).
- `SMTP_USERNAME` & `SMTP_PASSWORD`: Valid credentials for your SMTP server. For AWS SES, create SMTP credentials in the AWS console under SES > SMTP settings.

### Deploy Fast Retro!

You can now do your first deploy by running:

```sh
bin/kamal setup
```

This will set up Docker (if needed), build your Fast Retro app container, configure it, and start it running.

After the first deploy is done, any subsequent deploys won't need that initial setup. For future deploys, run:

```sh
bin/kamal deploy
```

### Useful Kamal commands

The deployment configuration includes helpful aliases:

```sh
bin/kamal console    # Open a Rails console on the server
bin/kamal shell      # Open a bash shell on the server
bin/kamal logs       # Tail application logs
bin/kamal dbc        # Open a database console
```

### Storage and persistence

Fast Retro uses SQLite for its database and stores files locally using Active Storage. The deployment is configured with a persistent Docker volume (`fastretrov2_prod_storage`) mounted at `/rails/storage`.

**Important:** For production use, we recommend backing up this volume regularly or mounting it to a path that is included in your server's backup strategy.

### Scaling considerations

The default configuration runs everything in a single container:

- Web server (Puma)
- Background jobs (Solid Queue, via `SOLID_QUEUE_IN_PUMA=true`)

For higher traffic, you can:

1. Increase `WEB_CONCURRENCY` to run more Puma workers
2. Split job processing to a dedicated server by uncommenting the `job` section in `servers`
3. Set `JOB_CONCURRENCY` to control the number of job worker threads

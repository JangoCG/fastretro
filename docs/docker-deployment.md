# Deploying with Docker
WIP

#### Multi-tenant mode

By default, when you run the Fast Retro Docker image you'll be limited to creating a single account (although that account can have as many users as you like).
This is for convenience: typically when you self-host you'll be running a single account, so in this mode new account signups are automatically disabled as soon as you've created your first account.

If you do want to allow multiple accounts to be created in your instance, set `MULTI_TENANT=true`
# Attachment processing with Hotcell

Fast Retro uses Rails 8.2 from `rails/rails` main, pinned to a commit in `Gemfile.lock`,
and Hotcell 0.6.0, matching Fizzy's Hotcell release. Rails configuration defaults stay
at 8.1, as in Fizzy. The Excel exporter also uses a locked upstream commit because
the released caxlsx 4.5.0 requires Marcel 1 and Rails 8.2 requires Marcel 2.

In SaaS production, image analysis and variants run in an unprivileged container on
the application's host. The cell has no network, credentials or database volume.
Inputs and outputs pass as file descriptors over Unix sockets. Only image operations
are installed: Fast Retro accepts JPEG, PNG, GIF and WebP uploads up to 10 MB.

The `saas` Docker target contains no libvips. The default `standalone` target keeps
local image processing for self-hosted deployments. Setting `HOTCELL_ROOT` opts any
deployment into Hotcell; SaaS production refuses to boot without it. An unavailable
configured cell raises a transient error and never falls back to local processing.

## Development

On macOS, run the cell as a native process: file descriptors cannot cross Docker's
Linux VM boundary. Install libvips with `brew install vips`, then run:

```sh
SAAS=true bin/setup --skip-server
SAAS=true bin/dev
```

`bin/dev` selects `Procfile.saas.dev` in SaaS mode. The cell has its own bundle and
runs with `--development`. Its sockets use a short path under `/tmp`, derived from
the user ID and a hash of the checkout path, so nested worktrees stay within Unix
socket path limits and separate checkouts do not share a cell. Set `HOTCELL_ROOT`
to choose another short socket root. Native tests use their own temporary root
under `/tmp`. Normal self-hosted development still uses `Procfile.dev`.

## Verification

```sh
BUNDLE_GEMFILE=hotcell/Gemfile bundle install
hotcell/bin/test
bin/ci
```

The Hotcell test starts a real native cell and checks metadata extraction, image
conversion, permanent rejection of invalid images, and failure without local fallback
when the socket is unavailable. It needs libvips. CI runs it on Linux as well.

## Deployment

Linux hosts must have `kernel.yama.ptrace_scope` set to 1 or higher. Hotcell refuses
to boot when it is 0, because workers could inspect one another's process memory.
Check this host prerequisite before booting the accessory.

Merge `hotcell/deploy.yml.example` into the private `config/deploy.yml`, preserving
the existing hosts, environment and storage volumes. Both mount points must exist
with group 10001. The images create them with that ownership, so either container
can mount a fresh volume first. Add `group-add: 10001` and the socket volume to every
app role that processes attachments, including a separate jobs role if introduced.

Build the cell locally. The default platform matches production's `linux/amd64`;
set `HOTCELL_PLATFORM=linux/arm64` for an ARM host. The image tag is a hash of its
Dockerfile, lockfile, configuration and operations, so changes produce a new tag.
`HOTCELL_IMAGE_REPOSITORY` defaults to `localhost:5555/fastretro-hotcell`; override
it consistently for both build and deployment if using another registry.

```sh
hotcell/bin/build
ruby hotcell/image.rb
```

When ready to release, publish the built image to the deployment's registry, boot
or reboot the accessory, then deploy the SaaS application target:

```sh
bin/kamal registry setup --skip-remote &&
docker push "$(ruby hotcell/image.rb)" &&
hotcell/bin/reboot &&
bin/kamal deploy
```

`hotcell/bin/reboot` forwards a `localhost:<port>` registry over SSH to the selected
cell hosts for the entire accessory reboot, using Kamal's SSH settings. It accepts
the same options as Kamal, including `-d staging` and `--hosts=host1,host2`. Pass the
same destination and host options to each Kamal command when narrowing a release.
The command also boots the accessory on its first release. A failure stops the
command chain before the application deploys.

For a remote registry, the publishing machine and production hosts must be able to
reach it, and any required accessory registry credentials must be configured in
Kamal. The reboot command then uses the normal pull without a registry tunnel.
Kamal does not update accessories as part of `deploy`; reboot the accessory whenever
its image changes. Keep the application and cell on the same Hotcell version and
retain both images when rolling back. The two lockfiles are checked by a test.

The accessory runs with no network, a read-only root, all capabilities dropped,
no new privileges, UID/GID 10001, and a capped `noexec,nosuid,nodev` temporary volume.
CPU, memory, process and per-operation deadlines are bounded. No app secrets belong
in the accessory's environment.

## Health and monitoring

`GET /hotcellz` is public and answers only `OK` or `FAIL`, with status 200 or 503.
It checks the supervisor's control socket without taking a worker.
`GET /hotcellz/test` requires staff authentication and exercises the work socket too,
including descriptor reopening. Run that diagnostic after changing the deployment.

SaaS metrics include the gem's Yabeda Hotcell metrics. Watch cell availability,
failed calls, queue saturation and killed workers. Permanently unreadable variants
return HTTP 422; transient job failures retry through the client gem's policy.

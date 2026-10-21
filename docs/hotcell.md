# Attachment processing with Hotcell

Fast Retro uses Rails 8.2 from `rails/rails` main, pinned to a commit in `Gemfile.lock`,
and Hotcell 0.6.0, matching Fizzy's Hotcell release. Rails configuration defaults stay
at 8.1, as in Fizzy. The Excel exporter also uses a locked upstream commit because
the released caxlsx 4.5.0 requires Marcel 1 and Rails 8.2 requires Marcel 2.

In SaaS production, attachment processing runs in an unprivileged container on each
web and jobs host. The cell has no network, credentials or database volume. Inputs
and outputs pass as file descriptors over Unix sockets. Like Fizzy, it includes
libvips image analysis and transforms, FFprobe audio/video analysis, MuPDF PDF
previews and FFmpeg video previews. Fast Retro's upload validation still accepts
JPEG, PNG, GIF and WebP up to 10 MB.

The `saas` Docker target contains none of these processing tools. The default `standalone` target keeps
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
`hotcell/test/check-test` exercises the deployment hooks and rollback pins against
isolated Docker, SSH and Kamal stubs; it never contacts deployment hosts.

## Deployment

Linux hosts must have `kernel.yama.ptrace_scope` set to 1 or higher. Hotcell refuses
to boot when it is 0, because workers could inspect one another's process memory.
Check this host prerequisite before booting the accessory.

The versioned `hotcell/deploy.yml` carries the shared SaaS deployment settings and
the literal cell image pin. Merge its settings into the private `config/deploy.yml`,
preserving existing hosts, environment, registry and storage volumes. The private
configuration reads the versioned pin with:

```erb
image: <%= require File.expand_path("hotcell/image", Dir.pwd); HotcellImage.pinned %>
```

Set `hooks_path: hotcell/hooks` in that configuration. The hooks apply to SaaS
deployments; the self-hosted deployment template keeps local image processing.
Both `web` and `jobs` roles share group 10001 and the socket volume. The jobs role
runs `bin/jobs`; remove `SOLID_QUEUE_IN_PUMA` so web containers do not start another
job supervisor. Both roles publish metrics on an automatically assigned loopback
port. The images create the socket mount points with group 10001, so either
container can mount a fresh socket volume first.

Build the cell locally. The default platform matches production's `linux/amd64`;
set `HOTCELL_PLATFORM=linux/arm64` for an ARM host. The image tag is a hash of its
Dockerfile, lockfile, configuration and operations, so changes produce a new tag.
`HOTCELL_IMAGE_REPOSITORY` defaults to `localhost:5555/fastretro-hotcell`.

```sh
hotcell/bin/build
git diff -- hotcell/Gemfile.lock hotcell/deploy.yml
```

The build first synchronizes the cell's Hotcell version with the application
lockfile, then builds and writes the immutable image pin. Commit the lockfiles,
cell inputs and pin together. `hotcell/bin/push` publishes an already built amd64
image; it rejects an arm64 image rather than publishing one production cannot run.

Deploy with the usual command:

```sh
bin/kamal deploy
```

The `pre-build` hook checks whether that application's pinned cell image is
published. If missing, it builds and publishes it before Kamal takes the deploy
lock. A build that changes the pin aborts the deployment so the new pin can be
committed first. This hook does not contact application hosts.

The `pre-deploy` hook checks the running cell under Kamal's deploy lock. It boots
or reboots a missing, stopped or outdated accessory onto the pinned image and
checks it again before the application deploys. A registry or SSH error stops the
deployment. Like Fizzy, a normal deployment samples one cell host; a narrower
`--hosts=host1,host2` deployment checks every selected cell host and reboots only
that selection. A selection without cell hosts needs no cell check.

Kamal invokes the same pre-deploy hook during rollback:

```sh
bin/kamal rollback APP_COMMIT
```

The hook reads `hotcell/deploy.yml` from `APP_COMMIT`, rather than the working
tree, and passes that image through `HOTCELL_IMAGE` to the accessory reboot.
Retain the published cell tags along with application releases. A rollback whose
image is missing stops; it never builds an old pin from different current inputs.
Dirty-tree deployment versions use the working tree pin, as in Fizzy.

The existing localhost registry stays in place. `hotcell/bin/reboot` forwards it
over SSH to the selected cell hosts for the entire accessory reboot, using
Kamal's SSH settings. The hooks use this helper automatically, including on the
first release. For a separate check or repair:

```sh
hotcell/bin/check
hotcell/bin/check --apply
hotcell/bin/check staging --version=APP_COMMIT --hosts=host1,host2 --reboot
```

The destination is optional and defaults to the base private configuration.
`--publish` performs the registry half only, `--reboot` the host half, and `--apply`
both. The check exits with 2 for a missing image, 3 for an accessory that needs a
reboot, and 1 when it cannot establish the state.

The accessory runs with no network, a read-only root, all capabilities dropped,
no new privileges, UID/GID 10001, and a capped `noexec,nosuid,nodev` temporary volume.
CPU, memory and process limits match Fizzy: 2 CPUs, 2 GiB memory without additional
swap and 512 processes. The cell allows four workers, eight queued requests, ten
seconds of queue wait, a 120-second operation deadline, 1536 MiB of worker memory and
256 MiB output files. The client waits 135 seconds to cover queueing and the reply.
The existing 512 MiB tmpfs scratch remains; Fizzy's host-mounted scratch filesystem
and private image registry are deliberately not adopted. No app secrets belong
in the accessory's environment.

## Health and monitoring

`GET /hotcellz` is public and answers only `OK` or `FAIL`, with status 200 or 503.
It checks the supervisor's control socket without taking a worker.
`GET /hotcellz/test` requires staff authentication and exercises the work socket too,
including descriptor reopening. Run that diagnostic after changing the deployment.

SaaS metrics include the gem's Yabeda Hotcell metrics. Watch cell availability,
failed calls, queue saturation and killed workers. Permanently unreadable variants
return HTTP 422; transient job failures retry through the client gem's policy.
Immediate variants from form uploads report a permanent failure without failing
the completed save or skipping later variants. Permanent failures are discarded
by the variant jobs; transient failures remain retryable.

## Fizzy source mapping

The implementation follows the local Fizzy checkout's Hotcell setup. Paths and the
SaaS namespace are adapted to Fast Retro; registry forwarding and tmpfs remain
Fast Retro's existing implementation.

| Fizzy reference | Fast Retro implementation |
| --- | --- |
| `[fizzy] saas/hotcell/bin/{build,push,check,image}` | `hotcell/bin/{build,push,check,image}`, `hotcell/image.rb` |
| `[fizzy] saas/.kamal/hooks/{pre-build,pre-deploy}` | `hotcell/hooks/{pre-build,pre-deploy}` |
| `[fizzy] saas/config/deploy.yml` | `hotcell/deploy.yml`, private `config/deploy.yml` |
| `[fizzy] saas/hotcell/{Dockerfile,config.rb,operations/active_storage.rb}` | corresponding files under `hotcell/` |
| `[fizzy] saas/lib/fizzy/saas/cell.rb` | `lib/fastretro/cell.rb`, registration in `config/application.rb` |
| `[fizzy] saas/lib/fizzy/saas/unprocessable_attachments.rb`, `engine.rb` | `lib/fastretro/unprocessable_attachments.rb`, `config/initializers/hotcell.rb` |
| `[fizzy] saas/test/hotcell-check-test` | `hotcell/test/check-test`, CI invocation in `config/ci.rb` and `.github/workflows/test.yml` |
| `[fizzy] saas/test/lib/{hotcell_accessory_test,hotcell_image_test}.rb` | corresponding files under `test/lib/` |

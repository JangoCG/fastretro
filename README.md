# Faster Retro

> **This is an unofficial fork.** Faster Retro is a fork of
> [JangoCG/fastretro](https://github.com/JangoCG/fastretro), the source of
> [Fast Retro](https://fastretro.app/). It is not affiliated with or endorsed by
> the original project or its maintainers. For the original, go upstream.

Faster Retro is a retrospective tool for remote teams — a way to run a
[sprint retrospective](https://www.scrum.org/resources/what-is-a-sprint-retrospective)
without the session sprawling across an afternoon.

## How this fork differs

- **Visual design.** A new design language: navy ink, a single hot-orange accent,
  pastel section tints, generous corner radii, and a Cabin/Inter type pairing.
- **Name.** The product is called Faster Retro. Internal module names, container
  image references, and file paths still read `fastretro` — renaming them would
  break deploys and buy nothing.

Everything else — the retrospective phases, real-time collaboration, multi-tenancy,
authentication — comes from upstream and is documented there.

## Running your own instance

### Docker

Upstream publishes pre-built images at `ghcr.io/jangocg/fastretro`. This fork does
not publish its own images; build from source or point your own registry at this
repository. See the [Docker deployment guide](docs/docker-deployment.md).

### Kamal

For more control over deployment, use [Kamal](https://kamal-deploy.org/). See the
[Kamal deployment guide](docs/kamal-deployment.md).

## Development

See the [Development guide](docs/development.md).

## Contributing

Contributions to this fork are welcome. Note that changes of general interest are
often better sent upstream to
[JangoCG/fastretro](https://github.com/JangoCG/fastretro) so the whole community
benefits.

## Credits

Fast Retro was created by [JangoCG](https://github.com/JangoCG) and its
contributors. This fork stands entirely on that work.

## License

Released under the [O'Saasy License](LICENSE.md), unchanged from upstream.

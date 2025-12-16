# Fast Retro

This is the source code of [Fast Retro](https://fastretro.app/), a tool which helps remote teams to carry out their [retrospectives](https://www.scrum.org/resources/what-is-a-sprint-retrospective) fast.


## Running your own Fast Retro instance

If you want to run your own Fast Retro instance, you can use Docker or deploy with Kamal.

### Docker

```bash
docker build -t fastretro .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name fastretro fastretro
```

### Kamal

For more flexibility to customize your Fast Retro installation and deploy changes to your server, we recommend deploying with [Kamal](https://kamal-deploy.org/). Configure `config/deploy.yml` for your environment.


## Development

Please see our [Development guide](docs/development.md) for how to get Fast Retro set up for local development.


## Contributing

We welcome contributions!


## License

Fast Retro is released under the [O'Saasy License](LICENSE.md).

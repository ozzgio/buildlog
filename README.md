# buildlog

A public build-log microblog — short daily entries about what I'm building and learning. The first app in a build-in-public Rails portfolio (a Shape Up "bet"). Public feed (unauthenticated), auth-gated posting for the single author.

## Stack

- Rails 8.1 (built-in auth, Solid Queue/Cache/Cable)
- SQLite in dev **and** production — no Postgres, no Redis
- Tailwind CSS v4 + DaisyUI 5 (`@plugin "daisyui"`; the npm `daisyui` package supplies the plugin, Tailwind is built by `tailwindcss-rails`)
- Kamal for deploy, GitHub Container Registry for images

## Local development

Requires Ruby 3.4.1 (`.ruby-version`) and Node 22.

```sh
npm install            # daisyUI Tailwind plugin (needed before the first asset build)
bin/rails db:prepare   # create + migrate the SQLite database
bin/dev                # foreman: Rails server + Tailwind watch → http://localhost:3000
```

Tests:

```sh
bin/rails test         # unit + integration (needs `npm install` — CI builds Tailwind first)
bin/rails test:system  # additionally needs Chrome/Chromium installed
```

## Deploy

Deployed with Kamal to a DigitalOcean droplet; images pushed to `ghcr.io/ozzgio/buildlog`. Servers, registry and secrets live in `config/deploy.yml` and `.kamal/secrets`:

- `RAILS_MASTER_KEY` is read from `config/master.key` — gitignored, never committed.
- `KAMAL_REGISTRY_PASSWORD` is resolved from `gh auth token` (requires the `write:packages` scope on the GitHub token).

```sh
bin/kamal deploy       # build → push to GHCR → pull + restart on the server
```

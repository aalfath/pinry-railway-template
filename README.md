# Pinry on Railway

This repo packages [Pinry](https://github.com/pinry/pinry), a self-hosted tiling image board for saving, tagging and sharing images, videos and web pages, as a one-click Railway template.

## What the template deploys

One service, **Pinry**, built from this repo's `Dockerfile`:

- Base image: the official `getpinry/pinry:2.1.13` (latest upstream release), pinned by digest `sha256:9a619749ec5246e04694adc479a135e654a7ac5f34c15d6d134d917a62b4889b`.
- Two security fixes that upstream merged after the 2.1.13 image was built ([pinry/pinry#388](https://github.com/pinry/pinry/pull/388)) are copied in unchanged from upstream commit `05476b1` (`patches/`).
- nginx serves the web app on `$PORT` and proxies `/api` and `/admin` to gunicorn (Django) on `127.0.0.1:8000`.
- A volume at `/data` holds the SQLite database, uploaded images and thumbnails.
- Health check: `/api/v2/profile/users/` (answers without login).

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `PINRY_ADMIN_USERNAME` | `admin` | Admin account created on the first start. |
| `PINRY_ADMIN_PASSWORD` | generated secret | Password for that account. Read it in the service's Variables tab. |
| `SECRET_KEY` | generated secret | Django secret key (signs sessions). |
| `PORT` | `8080` | Port nginx listens on. |

The admin account is created only once. Changing the two admin variables later does not change it: use the admin panel at `/admin/` to change passwords.

Optional variables you can add yourself:

| Variable | Default | Purpose |
|---|---|---|
| `PINRY_ALLOW_NEW_REGISTRATIONS` | `false` | Set to `true` to let visitors create their own accounts. |
| `PINRY_PUBLIC` | `true` | Set to `false` so only logged-in users can see pins. |
| `GUNICORN_WORKERS` | `2` | Number of gunicorn workers. |

## Updates

Railway tells everyone who deployed this template when a change is merged to `main`, and they choose when to apply it. Each change is listed in [`CHANGELOG.md`](CHANGELOG.md), breaking changes first. Back up the `/data` volume before applying an update.

## License

The wrapper files in this repo are provided under the same BSD-2-Clause license as Pinry. Pinry is © its contributors.

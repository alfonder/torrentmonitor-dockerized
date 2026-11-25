[![Latest Image](https://img.shields.io/docker/v/alfonder/torrentmonitor?color=lightgreen&label=latest)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Image](https://img.shields.io/docker/image-size/alfonder/torrentmonitor?sort=semver)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Build Status](https://img.shields.io/github/actions/workflow/status/alfonder/torrentmonitor-dockerized/deploy.yml?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized/actions/workflows/deploy.yml)
[![Last Commit](https://img.shields.io/github/last-commit/alfonder/torrentmonitor-dockerized?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized)

# TorrentMonitor Dockerized

[[Русская версия]](./README.md)

A Docker container for [TorrentMonitor](https://github.com/azinchen/TorrentMonitor), a web app
for tracking and automatically downloading torrents from multiple trackers. Built on Alpine Linux
with Nginx and PHP 8.5.

The image contains TorrentMonitor 4. It has no database: topics, tracker logins and settings are
kept in JSON files in the `/data/htdocs/db` volume. Volumes and compose files of earlier versions
work unchanged.

> 📖 **Full container documentation is in the [project Wiki](https://github.com/alfonder/torrentmonitor-dockerized/wiki)**
> (currently in Russian): installing Docker, running via `docker run` and Docker Compose, environment
> variables, the TOR + Transmission setup, troubleshooting and more.
>
> 📚 Documentation for the application itself (web interface, settings, supported trackers,
> torrent clients) is in the **[TorrentMonitor Wiki](https://github.com/azinchen/TorrentMonitor/wiki)**.

---

## Quick Start

1. **Install Docker:** [installation guide](https://docs.docker.com/engine/install/).

2. **Run the container:**

   ```bash
   docker container run -d \
     --name torrentmonitor \
     --restart unless-stopped \
     -p 8080:80 \
     -v torrentfiles:/data/htdocs/torrents \
     -v db:/data/htdocs/db \
     alfonder/torrentmonitor
   ```

3. **Open the web interface:** [http://localhost:8080](http://localhost:8080)

   A new installation shows a setup form: a password (or no password protection), the address of
   TorrentMonitor and, optionally, a torrent client. There is no default password. Complete the
   form right away: until it is completed, anyone who can open this address can complete it.

Data is stored in volumes and persists across container recreation. The `db` volume also holds the
passwords of trackers and of the torrent client, as plain text in `config.json`. Keep it private.

### Docker Compose

```yaml
services:
  torrentmonitor:
    container_name: torrentmonitor
    image: alfonder/torrentmonitor:latest
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./torrents:/data/htdocs/torrents
      - ./db:/data/htdocs/db
      - /etc/localtime:/etc/localtime:ro
    environment:
      - PHP_TIMEZONE=Europe/Moscow
      - CRON_TIMEOUT=0 * * * *
```

```bash
docker compose up -d
```

---

## Upgrading from 3.x

Make a copy of the `db` folder, update the image and recreate the container with the same volumes.
On the first start the container converts the old database (`tm.sqlite`) to the new files by itself
and reports it in the log (`docker container logs torrentmonitor`). Topics, tracker logins, settings
and the interface password are carried over. `tm.sqlite`, `config.xml` and `db_crypt.key` are left in
place as a backup and are not used afterwards.

Details: [Wiki: Updating and Maintenance](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Updating-and-Maintenance#переход-с-версии-3x-на-torrentmonitor-40).

---

## Main Environment Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `CRON_TIMEOUT` | `0 * * * *` | Update check schedule (cron format) |
| `PHP_TIMEZONE` | `UTC` | Timezone |
| `PHP_MEMORY_LIMIT` | `512M` | PHP memory limit |
| `NGINX_PORT` | `80` | Internal Nginx port |
| `PUID` / `PGID` | — | UID/GID for file ownership |
| `ENCRYPTION_KEY` | — | Encryption key of version 3.x; only needed for the data conversion on the first start of 4.0 |

Full reference: [Wiki: Environment Variables](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Environment-Variables).

---

## Image

```bash
docker pull alfonder/torrentmonitor:latest          # Docker Hub
docker pull ghcr.io/alfonder/torrentmonitor:latest  # GitHub Container Registry
```

Platforms: `amd64`, `arm64`, `arm/v7`, `arm/v6`, `riscv64`.

Tags: `latest`, `vX.X.X-X`, `legacy`, `devel`, `beta`.

See [Wiki: Platforms, Tags and Versions](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Platforms-Tags-and-Versions).

---

## Credits

Special thanks to [Eugene Elizarov](https://github.com/ElizarovEugene) for the
[TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor) app. Thanks to
[nawa](https://github.com/nawa) for the original
[`torrentmonitor-dockerized`](https://github.com/nawa/torrentmonitor-dockerized) project.

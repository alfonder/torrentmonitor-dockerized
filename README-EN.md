[![Latest Image](https://img.shields.io/docker/v/alfonder/torrentmonitor?color=lightgreen&label=latest)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Image](https://img.shields.io/docker/image-size/alfonder/torrentmonitor?sort=semver)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Build Status](https://img.shields.io/github/actions/workflow/status/alfonder/torrentmonitor-dockerized/deploy.yml?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized/actions/workflows/deploy.yml)
[![Last Commit](https://img.shields.io/github/last-commit/alfonder/torrentmonitor-dockerized?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized)

# TorrentMonitor Dockerized

[[Русская версия]](./README.md)

A Docker container for [TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor), a web app
for tracking and automatically downloading torrents from multiple trackers. Built on Alpine Linux
with Nginx and PHP 8.5.

> 📖 **Full container documentation is in the [project Wiki](https://github.com/alfonder/torrentmonitor-dockerized/wiki)**
> (currently in Russian): installing Docker, running via `docker run` and Docker Compose, environment
> variables, the TOR + Transmission setup, troubleshooting and more.
>
> 📚 Documentation for the application itself (web interface, settings, supported trackers,
> torrent clients) is in the **[TorrentMonitor Wiki](https://github.com/ElizarovEugene/TorrentMonitor/wiki)**.

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

Data is stored in volumes and persists across container recreation.

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

## Main Environment Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `CRON_TIMEOUT` | `0 * * * *` | Update check schedule (cron format) |
| `PHP_TIMEZONE` | `UTC` | Timezone |
| `PHP_MEMORY_LIMIT` | `512M` | PHP memory limit |
| `NGINX_PORT` | `80` | Internal Nginx port |
| `PUID` / `PGID` | — | UID/GID for file ownership |

Full reference: [Wiki: Environment Variables](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Environment-Variables).

---

## Image

```bash
docker pull alfonder/torrentmonitor:latest          # Docker Hub
docker pull ghcr.io/alfonder/torrentmonitor:latest  # GitHub Container Registry
```

Platforms: `amd64`, `arm64`, `arm/v7`, `arm/v6`, `riscv64`. Tags: `latest`, `vXXXX-X`, `legacy`, `devel`.
See [Wiki: Platforms, Tags and Versions](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Platforms-Tags-and-Versions).

---

## Credits

Special thanks to [Eugene Elizarov](https://github.com/ElizarovEugene) for the
[TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor) app. Thanks to
[nawa](https://github.com/nawa) for the original
[`torrentmonitor-dockerized`](https://github.com/nawa/torrentmonitor-dockerized) project.

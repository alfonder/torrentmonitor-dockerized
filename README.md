[![Latest Image](https://img.shields.io/docker/v/alfonder/torrentmonitor?color=lightgreen&label=latest)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Image](https://img.shields.io/docker/image-size/alfonder/torrentmonitor?sort=semver)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Build Status](https://img.shields.io/github/actions/workflow/status/alfonder/torrentmonitor-dockerized/deploy.yml?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized/actions/workflows/deploy.yml)
[![Last Commit](https://img.shields.io/github/last-commit/alfonder/torrentmonitor-dockerized?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized)

# TorrentMonitor Dockerized

[[Русская версия]](./README-RU.md)

A Docker container for [TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor), a web app for tracking and downloading torrents from multiple trackers.

---

## Supported Trackers

**Theme update tracking:**
- anidub.com
- animelayer.ru
- baibako.tv
- booktracker.org
- casstudio.tv
- hamsterstudio.org
- kinozal.me
- lostfilm.tv
- newstudio.tv
- nnmclub.to
- pornolab.net
- riperam.org
- rustorka.com
- rutor.info
- **rutracker.org**
- tfile.cc

**Release group update tracking:**
- booktracker.org
- nnm-club.ru
- pornolab.net
- rutracker.org
- tfile.me

**Feed scraping:**
- baibako.tv
- hamsterstudio.org
- lostfilm.tv (+ own mirror)
- newstudio.tv

---

## Credits

Special thanks to [nawa](https://github.com/nawa) for starting the original 'torrentmonitor-dockerized' project, which inspired this fork.

---

## Getting Started

### Basic Usage

1. **Install Docker:**  
   [Docker installation guide](https://docs.docker.com/engine/install/)

2. **Permissions:**  
   Use `sudo` with Docker commands or add your user to the `docker` group.

3. **Pull the image:**  
   From DockerHub:
   ```bash
   docker pull alfonder/torrentmonitor:latest
   ```
   Or from GitHub Registry:
   ```bash
   docker pull ghcr.io/alfonder/torrentmonitor:latest
   ```

4. **Create persistent volumes:**
   ```bash
   docker volume create torrentfiles
   docker volume create db
   ```

5. **Run the container:**
   ```bash
   docker container run -d \
     --name torrentmonitor \
     --restart unless-stopped \
     -p 8080:80 \
     -v torrentfiles:/data/htdocs/torrents \
     -v db:/data/htdocs/db \
     alfonder/torrentmonitor
   ```
   Your data will persist even if you delete or recreate the container.

6. **Access the web interface:**  
   Open [http://localhost:8080](http://localhost:8080) in your browser.

7. **Configure and use the application.**

---

### Advanced Usage

#### Environment Variables

You can customize TorrentMonitor behavior using these environment variables:

- `CRON_TIMEOUT="0 */3 * * *"` — Cron schedule (default: every hour)
- `CRON_COMMAND="<...>"` — Custom update command (default: `php -q /data/htdocs/engine.php`)
- `PHP_TIMEZONE="Europe/Moscow"` — PHP timezone (default: UTC)
- `PHP_MEMORY_LIMIT="512M"` — PHP memory limit (default: 512M)
- `PUID=<number>` — User ID for file ownership
- `PGID=<number>` — Group ID for file ownership
- `QBITTORRENT_CATEGORY="<category>"` — qBittorrent category for Sonarr integration

#### Port Configuration

Change the server port by editing the `-p` option in your Docker command.

#### Timezone Configuration

To use the host's timezone, add a localtime binding:
```bash
-v /etc/localtime:/etc/localtime:ro
```

#### Complete Example

```bash
docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v <path_to_torrents_folder>:/data/htdocs/torrents \
  -v <path_to_db_folder>:/data/htdocs/db \
  -v /etc/localtime:/etc/localtime:ro \
  -e PHP_TIMEZONE="Europe/Moscow" \
  -e CRON_TIMEOUT="15 8-23 * * *" \
  -e QBITTORRENT_CATEGORY="tv-sonarr" \
  -e PUID=1001 \
  -e PGID=1000 \
  alfonder/torrentmonitor
```

#### Sonarr Integration

TorrentMonitor supports integration with [Sonarr](https://sonarr.tv/) through the `QBITTORRENT_CATEGORY` environment variable. This feature allows TorrentMonitor to work seamlessly with existing Sonarr + qBittorrent setups.

**How to use:**
1. **Prerequisites:** Ensure you have a working Sonarr + qBittorrent setup with a configured category (e.g., "tv-sonarr").
2. **Configuration:** Configure both Sonarr and qBittorrent to NOT automatically delete completed torrents.
3. **Setup TorrentMonitor:** Launch TorrentMonitor with the `QBITTORRENT_CATEGORY` environment variable matching your Sonarr category.
4. **Workflow:** 
   - Add a TV series to Sonarr
   - Sonarr will automatically download a torrent to qBittorrent
   - Remove the torrent from qBittorrent
   - Add the same tracker page (or a better alternative) to TorrentMonitor for monitoring
   - TorrentMonitor will watch the tracker page for updates and download new episodes to the same category
   - Sonarr will automatically detect new episodes in the category and process them (rename, move to library, etc.)

**Important:** When using the `QBITTORRENT_CATEGORY` feature, you **must disable auto-updating** in TorrentMonitor's web interface. Self-updates will overwrite the category configuration and break the Sonarr integration. To disable auto-updates, go to TorrentMonitor settings and turn off automatic updates.

---

### Using Docker Compose

You can run TorrentMonitor with either classic Docker Compose (`docker-compose`) or Docker Compose v2 (`docker compose`). Both methods are supported.

#### Docker Compose v2 (recommended)

1. **Create a `docker-compose.yml` file:**
   ```yaml
   version: '3'

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
         - QBITTORRENT_CATEGORY=tv-sonarr
   ```

2. **(Optional) Create a `.env` file** to override variables in your compose file:
   ```env
   PHP_TIMEZONE=Europe/Moscow
   CRON_TIMEOUT=0 * * * *
   QBITTORRENT_CATEGORY=tv-sonarr
   ```

3. **Start the service:**
   ```bash
   docker compose up -d
   ```

4. **Stop the service:**
   ```bash
   docker compose down
   ```

#### Classic Docker Compose

You can use the same `docker-compose.yml` file as above.

1. **Start the service:**
   ```bash
   docker-compose up -d
   ```

2. **Stop the service:**
   ```bash
   docker-compose down
   ```

Both `docker compose` (v2) and `docker-compose` (classic) commands are supported. Use whichever matches your Docker installation.

---

### TorrentMonitor + TOR + Transmission

You can run TorrentMonitor together with Transmission and TOR using `docker-compose`. See the [example script](examples/docker-compose.yml).

---

### Useful Commands

```bash
docker container stop torrentmonitor
docker container start torrentmonitor
docker container restart torrentmonitor
```

---

### Version Info

To check the running container version:
```bash
docker container inspect -f '{{ index .Config.Labels "ru.korphome.version" }}' torrentmonitor
```

---

## Platform Support

Images are available for:
- **x86-64** - Intel/AMD 64-bit processors, most desktop/server PCs
- **x86** - Intel/AMD 32-bit processors, older PCs
- **arm64** - 64-bit ARM processors (Raspberry Pi 4+, Raspberry Pi Compute Module 4, Apple Silicon Macs via Docker Desktop, AWS Graviton instances, NVIDIA Jetson boards, ODROID-N2+, Orange Pi 5, Rock Pi 4, Banana Pi M5)
- **arm32v7** - 32-bit ARMv7 processors (Raspberry Pi 2/3, Raspberry Pi Zero 2 W, Raspberry Pi Compute Module 3, BeagleBone Black, ODROID-XU4, ASUS Tinker Board, Orange Pi PC, Banana Pi M2+, NanoPi NEO)
- **arm32v6** - 32-bit ARMv6 processors (Raspberry Pi 1 Model A/B, Raspberry Pi Zero/Zero W, Raspberry Pi Compute Module 1)
- **ppc64le** - IBM POWER processors (IBM servers, mainframes)

Other platforms can be added on request.

---

## OS Support

**Linux:**  
Use Docker directly. The correct image will be pulled automatically.

**Windows & macOS:**  
Use Docker Desktop (Windows 10 Pro/Enterprise 64-bit with Hyper-V, or macOS Yosemite 10.10.3+).  
[Download Docker Desktop](https://www.docker.com/products/docker-desktop)

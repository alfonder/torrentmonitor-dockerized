[![Latest Image](https://img.shields.io/docker/v/alfonder/torrentmonitor?color=lightgreen&label=latest)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Image](https://img.shields.io/docker/image-size/alfonder/torrentmonitor?sort=semver)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Build Status](https://img.shields.io/github/actions/workflow/status/alfonder/torrentmonitor-dockerized/deploy.yml?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized/actions/workflows/deploy.yml)
[![Last Commit](https://img.shields.io/github/last-commit/alfonder/torrentmonitor-dockerized?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized)

# TorrentMonitor в Docker

[[English version]](./README-EN.md)

Контейнер Docker для [TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor) — веб-приложения
для отслеживания и автоматической загрузки торрентов с различных трекеров. Собран на Alpine Linux с
Nginx и PHP 8.5.

> 📖 **Подробная документация по контейнеру — в [Вики проекта](https://github.com/alfonder/torrentmonitor-dockerized/wiki):**
> установка Docker, запуск через `docker run` и Docker Compose, переменные окружения,
> связка с TOR + Transmission, решение проблем и многое другое.
>
> 📚 Документация самого приложения (веб-интерфейс, настройки, поддерживаемые трекеры,
> торрент-клиенты) — в **[Вики TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor/wiki)**.

---

## Быстрый старт

1. **Установите Docker:** [инструкция по установке](https://docs.docker.com/engine/install/)
   (подробно — в [Вики](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Installing-Docker)).

2. **Запустите контейнер:**

   ```bash
   docker container run -d \
     --name torrentmonitor \
     --restart unless-stopped \
     -p 8080:80 \
     -v torrentfiles:/data/htdocs/torrents \
     -v db:/data/htdocs/db \
     alfonder/torrentmonitor
   ```

3. **Откройте веб-интерфейс:** [http://localhost:8080](http://localhost:8080)

Данные хранятся в томах и сохраняются при пересоздании контейнера.

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

## Основные переменные окружения

| Переменная | По умолчанию | Назначение |
| --- | --- | --- |
| `CRON_TIMEOUT` | `0 * * * *` | Расписание проверок (формат cron) |
| `PHP_TIMEZONE` | `UTC` | Часовой пояс |
| `PHP_MEMORY_LIMIT` | `512M` | Лимит памяти PHP |
| `NGINX_PORT` | `80` | Внутренний порт Nginx |
| `PUID` / `PGID` | — | UID/GID для прав на файлы |

Полный справочник — в [Вики: Переменные окружения](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Environment-Variables).

---

## Образ

```bash
docker pull alfonder/torrentmonitor:latest          # Docker Hub
docker pull ghcr.io/alfonder/torrentmonitor:latest  # GitHub Container Registry
```

Платформы: `amd64`, `arm64`, `arm/v7`, `arm/v6`, `riscv64`.

Теги: `latest`, `vX.X.X-X`, `legacy`, `devel`, `beta`.

Подробнее — в [Вики: Платформы, теги и версии](https://github.com/alfonder/torrentmonitor-dockerized/wiki/Platforms-Tags-and-Versions).

---

## Благодарности

Особая благодарность [Евгению Елизарову](https://github.com/ElizarovEugene) за приложение
[TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor). Спасибо [nawa](https://github.com/nawa)
за исходный проект [`torrentmonitor-dockerized`](https://github.com/nawa/torrentmonitor-dockerized).

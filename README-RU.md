[![Latest Image](https://img.shields.io/docker/v/alfonder/torrentmonitor?color=lightgreen&label=latest)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Image](https://img.shields.io/docker/image-size/alfonder/torrentmonitor?sort=semver)](https://hub.docker.com/r/alfonder/torrentmonitor)
[![Build Status](https://img.shields.io/github/actions/workflow/status/alfonder/torrentmonitor-dockerized/deploy.yml?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized/actions/workflows/deploy.yml)
[![Last Commit](https://img.shields.io/github/last-commit/alfonder/torrentmonitor-dockerized?logo=github)](https://github.com/alfonder/torrentmonitor-dockerized)

# TorrentMonitor в Docker

[[English version]](./README.md)

Контейнер Docker для [TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor) — веб-приложения для отслеживания и загрузки торрентов с различных трекеров.

---

## Поддерживаемые трекеры

**Отслеживание обновлений тем:**
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

**Отслеживание групп релизов:**
- booktracker.org
- nnm-club.ru
- pornolab.net
- rutracker.org
- tfile.me

**Парсинг лент:**
- baibako.tv
- hamsterstudio.org
- lostfilm.tv (+ собственное зеркало)
- newstudio.tv

---

## Благодарности

Особая благодарность [nawa](https://github.com/nawa) за создание оригинального проекта 'torrentmonitor-dockerized', который вдохновил на этот форк.

---

## Быстрый старт

### Основное использование

1. **Установите Docker:**  
   [Инструкция по установке Docker](https://docs.docker.com/engine/install/)

2. **Права доступа:**  
   Используйте `sudo` с командами Docker или добавьте пользователя в группу `docker`.

3. **Скачайте образ:**  
   С DockerHub:
   ```bash
   docker pull alfonder/torrentmonitor:latest
   ```
   Или из GitHub Registry:
   ```bash
   docker pull ghcr.io/alfonder/torrentmonitor:latest
   ```

4. **Создайте постоянные тома:**
   ```bash
   docker volume create torrentfiles
   docker volume create db
   ```

5. **Запустите контейнер:**
   ```bash
   docker container run -d \
     --name torrentmonitor \
     --restart unless-stopped \
     -p 8080:80 \
     -v torrentfiles:/data/htdocs/torrents \
     -v db:/data/htdocs/db \
     alfonder/torrentmonitor
   ```
   Ваши данные сохранятся даже при удалении или пересоздании контейнера.

6. **Откройте веб-интерфейс:**  
   Перейдите в браузере по адресу [http://localhost:8080](http://localhost:8080)

7. **Настройте и пользуйтесь приложением.**

---

### Расширенное использование

#### Переменные окружения

Вы можете настроить поведение TorrentMonitor с помощью этих переменных окружения:

- `CRON_TIMEOUT="0 */3 * * *"` — расписание cron (по умолчанию: каждый час)
- `CRON_COMMAND="<...>"` — команда обновления (по умолчанию: `php -q /data/htdocs/engine.php`)
- `PHP_TIMEZONE="Europe/Moscow"` — часовой пояс PHP (по умолчанию: UTC)
- `PHP_MEMORY_LIMIT="512M"` — лимит памяти PHP (по умолчанию: 512M)
- `PUID=<номер>` — UID пользователя для прав на файлы
- `PGID=<номер>` — GID группы для прав на файлы
- `QBITTORRENT_CATEGORY="<категория>"` — категория qBittorrent для интеграции с Sonarr

#### Настройка порта

Измените порт сервера через опцию `-p` в команде Docker.

#### Настройка часового пояса

Для использования часового пояса хоста добавьте монтирование localtime:
```bash
-v /etc/localtime:/etc/localtime:ro
```

#### Полный пример

```bash
docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v <путь_к_папке_торрентов>:/data/htdocs/torrents \
  -v <путь_к_папке_db>:/data/htdocs/db \
  -v /etc/localtime:/etc/localtime:ro \
  -e PHP_TIMEZONE="Europe/Moscow" \
  -e CRON_TIMEOUT="15 8-23 * * *" \
  -e QBITTORRENT_CATEGORY="tv-sonarr" \
  -e PUID=1001 \
  -e PGID=1000 \
  alfonder/torrentmonitor
```

#### Интеграция с Sonarr

TorrentMonitor поддерживает интеграцию с [Sonarr](https://sonarr.tv/) через переменную окружения `QBITTORRENT_CATEGORY`. Эта функция позволяет TorrentMonitor бесшовно работать с существующими настройками Sonarr + qBittorrent.

**Как использовать:**
1. **Предварительные требования:** Убедитесь, что у вас есть рабочая связка Sonarr + qBittorrent с настроенной категорией (например, "tv-sonarr").
2. **Настройка:** Настройте Sonarr и qBittorrent так, чтобы они НЕ удаляли автоматически завершённые торренты.
3. **Настройка TorrentMonitor:** Запустите TorrentMonitor с переменной окружения `QBITTORRENT_CATEGORY`, соответствующей вашей категории Sonarr.
4. **Порядок действий:**
   - Добавьте сериал в Sonarr
   - Sonarr автоматически загрузит торрент в qBittorrent
   - Удалите торрент из qBittorrent
   - Добавьте ту же страницу трекера (или лучшую альтернативу) в TorrentMonitor для мониторинга
   - TorrentMonitor будет отслеживать страницу трекера на предмет обновлений и загружать новые эпизоды в ту же категорию
   - Sonarr автоматически обнаружит новые эпизоды в категории и обработает их (переименует, переместит в библиотеку и т.д.)

**Примечание:** Контейнер автоматически отслеживает обновления TorrentMonitor и повторно применяет конфигурацию категории qBittorrent, если она перезаписывается во время автоматических обновлений. Это гарантирует, что интеграция с Sonarr продолжит работать даже после самообновления TorrentMonitor.

---

### Использование Docker Compose

Вы можете использовать как классический Docker Compose (`docker-compose`), так и Docker Compose v2 (`docker compose`). Оба варианта поддерживаются.

#### Docker Compose v2 (рекомендуется)

1. **Создайте файл `docker-compose.yml`:**
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
         - QBITTORRENT_CATEGORY=tv-sonarr
   ```

2. **(Опционально) создайте `.env` для переменных:**
   ```env
   PHP_TIMEZONE=Europe/Moscow
   CRON_TIMEOUT=0 * * * *
   QBITTORRENT_CATEGORY=tv-sonarr
   ```

3. **Запустите сервис:**
   ```bash
   docker compose up -d
   ```

4. **Остановите сервис:**
   ```bash
   docker compose down
   ```

#### Классический Docker Compose

Используйте тот же файл `docker-compose.yml`.

1. **Запуск:**
   ```bash
   docker-compose up -d
   ```

2. **Остановка:**
   ```bash
   docker-compose down
   ```

---

### TorrentMonitor + TOR + Transmission

Можно запускать TorrentMonitor вместе с Transmission и TOR через `docker-compose`. Пример смотрите в [examples/docker-compose.yml](examples/docker-compose.yml).

---

### Полезные команды

```bash
docker container stop torrentmonitor
docker container start torrentmonitor
docker container restart torrentmonitor
```

---

### Информация о версии

Проверить версию контейнера:
```bash
docker container inspect -f '{{ index .Config.Labels "ru.korphome.version" }}' torrentmonitor
```

---

## Поддерживаемые платформы

Доступны образы для:
- **x86-64** - 64-битные процессоры Intel/AMD, большинство ПК/серверов
- **x86** - 32-битные процессоры Intel/AMD, старые ПК
- **arm64** - 64-битные ARM процессоры (Raspberry Pi 4+, Raspberry Pi Compute Module 4, Apple Silicon Mac через Docker Desktop, AWS Graviton инстансы, платы NVIDIA Jetson, ODROID-N2+, Orange Pi 5, Rock Pi 4, Banana Pi M5)
- **arm32v7** - 32-битные ARMv7 процессоры (Raspberry Pi 2/3, Raspberry Pi Zero 2 W, Raspberry Pi Compute Module 3, BeagleBone Black, ODROID-XU4, ASUS Tinker Board, Orange Pi PC, Banana Pi M2+, NanoPi NEO)
- **arm32v6** - 32-битные ARMv6 процессоры (Raspberry Pi 1 Model A/B, Raspberry Pi Zero/Zero W, Raspberry Pi Compute Module 1)
- **ppc64le** - процессоры IBM POWER (серверы IBM, мейнфреймы)

Другие платформы — по запросу.

---

## Поддержка ОС

**Linux:**  
Используйте Docker напрямую. Подходящий образ будет выбран автоматически.

**Windows & macOS:**  
Используйте Docker Desktop (Windows 10 Pro/Enterprise 64-bit с Hyper-V или macOS Yosemite 10.10.3+).  
[Скачать Docker Desktop](https://www.docker.com/products/docker-desktop)

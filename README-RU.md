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

- Измените порт сервера через опцию `-p`.
- Используйте переменные окружения для настройки:
  - `CRON_TIMEOUT="0 */3 * * *"` — расписание cron (по умолчанию: каждый час)
  - `CRON_COMMAND="<...>"` — команда обновления (по умолчанию: `php -q /data/htdocs/engine.php`)
  - `PHP_TIMEZONE="Europe/Moscow"` — часовой пояс PHP (по умолчанию: UTC)
  - `PHP_MEMORY_LIMIT="512M"` — лимит памяти PHP (по умолчанию: 512M)
  - `PUID=<номер>` — UID пользователя для прав на файлы
  - `PGID=<номер>` — GID группы для прав на файлы
- Для использования часового пояса хоста добавьте монтирование localtime.

**Пример:**
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
  -e PUID=1001 \
  -e PGID=1000 \
  alfonder/torrentmonitor
```

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
   ```

2. **(Опционально) создайте `.env` для переменных:**
   ```env
   PHP_TIMEZONE=Europe/Moscow
   CRON_TIMEOUT=0 * * * *
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
- x86-64
- x86
- arm64
- arm32
- ppc64le

Другие платформы (например, s390x, mips) — по запросу.

---

## Поддержка ОС

**Linux:**  
Используйте Docker напрямую. Подходящий образ будет выбран автоматически.

**Windows & macOS:**  
Используйте Docker Desktop (Windows 10 Pro/Enterprise 64-bit с Hyper-V или macOS Yosemite 10.10.3+).  
[Скачать Docker Desktop](https://www.docker.com/products/docker-desktop)

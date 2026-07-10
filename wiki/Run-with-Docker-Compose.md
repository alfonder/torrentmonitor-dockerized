# Запуск через Docker Compose

Docker Compose описывает контейнер в одном YAML-файле. Это рекомендуемый способ для постоянной
работы: всю конфигурацию видно в одном месте, а изменить параметры можно простым редактированием
файла без длинных команд.

Поддерживаются оба варианта:
- **Docker Compose v2** — команда `docker compose` (через пробел), современный плагин. **Рекомендуется.**
- **Классический Docker Compose** — команда `docker-compose` (через дефис), устаревшая утилита.

---

## Шаг 1. Создайте `docker-compose.yml`

Создайте папку для проекта и в ней файл `docker-compose.yml`:

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

В этом примере данные хранятся в подпапках `./torrents` и `./db` рядом с файлом compose.

---

## Шаг 2. Запустите сервис

```bash
docker compose up -d
```

Интерфейс будет доступен на <http://localhost:8080>.

---

## Шаг 3. Управление

```bash
docker compose ps          # статус контейнера
docker compose logs -f     # логи в реальном времени
docker compose restart     # перезапуск
docker compose stop        # остановить (без удаления)
docker compose start       # запустить снова
docker compose down        # остановить и удалить контейнер (данные в томах/папках сохранятся)
```

---

## Использование `.env` для переменных

Чтобы не хранить значения прямо в `docker-compose.yml`, вынесите их в файл `.env` рядом с ним.
Compose автоматически подставит переменные `${...}`.

**`.env`:**

```env
# Тег образа
TM_TAG=latest

# Имя контейнера
SERVICENAME=torrentmonitor

# Порт веб-интерфейса на хосте
LISTEN_PORT=8080

# Папка для постоянных данных контейнера
DATA_DIR=/opt/torrentmonitor

# Расписание запуска в формате cron
SCHEDULE=0 * * * *

# Часовой пояс
TIMEZONE=Europe/Moscow
```

**`docker-compose.yml`:**

```yaml
services:
  torrentmonitor:
    container_name: ${SERVICENAME}
    image: alfonder/torrentmonitor:${TM_TAG}
    restart: unless-stopped
    ports:
      - ${LISTEN_PORT}:80
    volumes:
      - ${DATA_DIR}/torrents:/data/htdocs/torrents
      - ${DATA_DIR}/db:/data/htdocs/db
      - ${DATA_DIR}/logs:/data/htdocs/logs
      - /etc/localtime:/etc/localtime:ro
    environment:
      - PHP_TIMEZONE=${TIMEZONE}
      - CRON_TIMEOUT=${SCHEDULE}
```

Теперь, чтобы поменять порт или расписание, достаточно отредактировать `.env` и выполнить
`docker compose up -d` — Compose пересоздаст контейнер с новыми параметрами.

> 📄 Это та же схема, что лежит в репозитории в файлах `docker-compose.yml` и `.env`.

---

## Обновление через Compose

```bash
docker compose pull       # скачать свежий образ
docker compose up -d      # пересоздать контейнер на новом образе
docker image prune -f     # (опционально) удалить старые образы
```

Подробнее — на странице **[Обновление и обслуживание](Updating-and-Maintenance)**.

---

## Классический `docker-compose`

Если у вас старая утилита `docker-compose` (через дефис), используйте тот же `docker-compose.yml`,
просто замените команду:

```bash
docker-compose up -d
docker-compose down
```

> ⚠️ В классическом `docker-compose` иногда требуется первой строкой указать версию формата,
> например `version: '3'`. В Compose v2 строка `version` не нужна и считается устаревшей.

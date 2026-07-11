# Обновление и обслуживание

---

## Обновление образа

Образ регулярно пересобирается со свежей версией TorrentMonitor и обновлённым Alpine Linux.
Рекомендуется обновляться вместо использования встроенного автообновления приложения.

### docker run

```bash
# 1. Скачать свежий образ
docker pull alfonder/torrentmonitor:latest

# 2. Остановить и удалить старый контейнер (данные в томах сохранятся)
docker container rm -f torrentmonitor

# 3. Запустить заново с теми же параметрами и томами
docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v torrentfiles:/data/htdocs/torrents \
  -v db:/data/htdocs/db \
  alfonder/torrentmonitor

# 4. (опционально) удалить устаревшие образы
docker image prune -f
```

### docker compose

```bash
docker compose pull       # скачать свежий образ
docker compose up -d      # пересоздать контейнер на новом образе
docker image prune -f     # (опционально) убрать старые образы
```

> 💾 Перед обновлением сделайте бэкап папки/тома `db` — см.
> **[Тома и постоянные данные](Volumes-and-Data#резервное-копирование)**.

---

## Проверка текущей версии

Версия приложения зашита в метку (label) образа:

```bash
docker container inspect -f '{{ index .Config.Labels "torrentmonitor.app.version" }}' torrentmonitor
```

Полезные метки образа:

| Метка | Содержит |
| --- | --- |
| `torrentmonitor.app.version` | версия приложения TorrentMonitor |
| `torrentmonitor.app.release-date` | дата релиза приложения |
| `org.opencontainers.image.version` | версия сборки Dockerized |
| `org.opencontainers.image.created` | дата сборки образа |

Посмотреть все метки сразу:

```bash
docker image inspect alfonder/torrentmonitor:latest -f '{{ json .Config.Labels }}'
```

---

## Логи

```bash
docker container logs torrentmonitor        # весь лог
docker container logs -f torrentmonitor     # следить в реальном времени
docker container logs --tail 100 torrentmonitor   # последние 100 строк
```

Если в Compose примонтирована папка `logs` (`/data/htdocs/logs`), логи приложения также доступны
прямо в этой папке на хосте.

---

## Запуск проверки трекеров вручную

Не дожидаясь расписания cron:

```bash
docker exec torrentmonitor php -q /data/htdocs/engine.php
```

---

## Очистка

```bash
docker image prune -f         # удалить «висячие» (dangling) образы
docker container prune -f     # удалить остановленные контейнеры
docker system df              # сколько места занимает Docker
```

> ⚠️ Не используйте `docker volume prune`, если не уверены — это может удалить тома с вашей базой
> данных.

---

## Перенос на другой сервер

1. Сделайте бэкап тома/папки `db` (и при желании `torrents`).
2. Установите Docker на новом сервере.
3. Восстановите данные в том же пути.
4. Запустите контейнер с теми же томами и параметрами.

Поскольку вся конфигурация хранится в `db/`, приложение поднимется в том же состоянии.

# Быстрый старт

Эта страница поможет запустить TorrentMonitor за несколько минут. Предполагается, что Docker уже
установлен — если нет, смотрите **[Установка Docker](Installing-Docker)**.

---

## Шаг 1. Скачайте образ

С Docker Hub:

```bash
docker pull alfonder/torrentmonitor:latest
```

Или из GitHub Container Registry:

```bash
docker pull ghcr.io/alfonder/torrentmonitor:latest
```

> Этот шаг можно пропустить — при первом запуске образ скачается автоматически.

---

## Шаг 2. Создайте тома для данных

Тома (volumes) хранят базу данных и скачанные `.torrent`-файлы отдельно от контейнера, поэтому
ваши данные **не пропадут** при пересоздании или обновлении контейнера.

```bash
docker volume create torrentfiles
docker volume create db
```

Подробнее — на странице **[Тома и постоянные данные](Volumes-and-Data)**.

---

## Шаг 3. Запустите контейнер

```bash
docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v torrentfiles:/data/htdocs/torrents \
  -v db:/data/htdocs/db \
  alfonder/torrentmonitor
```

Что означают параметры:

| Параметр | Назначение |
| --- | --- |
| `-d` | запуск в фоне (detached) |
| `--name torrentmonitor` | имя контейнера для удобства управления |
| `--restart unless-stopped` | автозапуск после перезагрузки хоста |
| `-p 8080:80` | проброс порта: `8080` на хосте → `80` в контейнере |
| `-v torrentfiles:/data/htdocs/torrents` | том для `.torrent`-файлов |
| `-v db:/data/htdocs/db` | том для базы данных и настроек |

Подробный разбор всех опций — на странице **[Запуск через `docker run`](Run-with-docker-run)**.

---

## Шаг 4. Откройте веб-интерфейс

Перейдите в браузере по адресу:

👉 **<http://localhost:8080>**

Если контейнер запущен на другом компьютере или сервере, замените `localhost` на его IP-адрес,
например `http://192.168.1.50:8080`.

---

## Шаг 5. Настройте приложение

Войдите в веб-интерфейс и выполните первичную настройку: укажите торрент-клиент, добавьте трекеры
и раздачи для мониторинга — по инструкциям из
**[Вики TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor/wiki)**. Особенности
работы в контейнере (адресация клиентов, расписание проверок) — на странице
**[Настройка и использование](Configuration-and-Usage)**.

---

## Управление контейнером

```bash
docker container stop torrentmonitor      # остановить
docker container start torrentmonitor     # запустить
docker container restart torrentmonitor   # перезапустить
docker container logs -f torrentmonitor   # смотреть логи
```

---

## Что дальше?

- ⚙️ Тонкая настройка через **[Переменные окружения](Environment-Variables)** (часовой пояс, расписание и т.д.).
- 🧩 Удобнее управлять через **[Docker Compose](Run-with-Docker-Compose)** вместо длинных команд.

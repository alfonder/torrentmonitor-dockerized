# Запуск через `docker run`

Команда `docker run` запускает контейнер одной строкой. Это самый быстрый способ для разовых
запусков и экспериментов. Для постоянной эксплуатации удобнее
**[Docker Compose](Run-with-Docker-Compose)**.

---

## Минимальный запуск

```bash
docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v torrentfiles:/data/htdocs/torrents \
  -v db:/data/htdocs/db \
  alfonder/torrentmonitor
```

После запуска интерфейс доступен на <http://localhost:8080>.

---

## Разбор параметров

| Параметр | Описание |
| --- | --- |
| `-d`, `--detach` | Запуск в фоновом режиме. |
| `--name torrentmonitor` | Имя контейнера. Без него Docker присвоит случайное. |
| `--restart unless-stopped` | Политика перезапуска: контейнер поднимется после перезагрузки хоста, но не если вы остановили его вручную. |
| `-p 8080:80` | Проброс портов `ХОСТ:КОНТЕЙНЕР`. Внутри контейнера Nginx слушает порт `80`. |
| `-v ...:/data/htdocs/torrents` | Том для скачанных `.torrent`-файлов. |
| `-v ...:/data/htdocs/db` | Том для базы данных SQLite и файла настроек. |
| `-e ПЕРЕМЕННАЯ=значение` | Переменные окружения (см. ниже). |
| `alfonder/torrentmonitor` | Имя образа. Без тега подставляется `:latest`. |

> 📂 Полный список томов и внутренних путей — на странице **[Тома и постоянные данные](Volumes-and-Data)**.
> 🔧 Полный список переменных — на странице **[Переменные окружения](Environment-Variables)**.

---

## Именованные тома vs. папки хоста

### Вариант А. Именованные тома (управляются Docker)

```bash
docker volume create torrentfiles
docker volume create db

docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v torrentfiles:/data/htdocs/torrents \
  -v db:/data/htdocs/db \
  alfonder/torrentmonitor
```

### Вариант Б. Папки на хосте (bind mount)

Удобно, если хотите видеть файлы прямо в файловой системе хоста:

```bash
mkdir -p /opt/torrentmonitor/torrents /opt/torrentmonitor/db

docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v /opt/torrentmonitor/torrents:/data/htdocs/torrents \
  -v /opt/torrentmonitor/db:/data/htdocs/db \
  alfonder/torrentmonitor
```

---

## Настройка порта

Чтобы открыть сервис на другом порту хоста, измените левую часть в `-p`:

```bash
-p 3000:80   # интерфейс будет доступен на http://localhost:3000
```

Если нужно изменить **внутренний** порт Nginx (например, при особых сетевых настройках),
используйте переменную `NGINX_PORT` и согласуйте её с правой частью `-p`:

```bash
-p 8081:8081 -e NGINX_PORT=8081
```

---

## Часовой пояс

По умолчанию используется UTC. Чтобы задать часовой пояс:

```bash
-e PHP_TIMEZONE="Europe/Moscow"
```

Чтобы дополнительно синхронизировать системное время контейнера с хостом:

```bash
-v /etc/localtime:/etc/localtime:ro
```

---

## Полный пример со всеми опциями

```bash
docker container run -d \
  --name torrentmonitor \
  --restart unless-stopped \
  -p 8080:80 \
  -v /opt/torrentmonitor/torrents:/data/htdocs/torrents \
  -v /opt/torrentmonitor/db:/data/htdocs/db \
  -v /etc/localtime:/etc/localtime:ro \
  -e PHP_TIMEZONE="Europe/Moscow" \
  -e CRON_TIMEOUT="15 8-23 * * *" \
  -e PHP_MEMORY_LIMIT="512M" \
  -e PUID=1001 \
  -e PGID=1000 \
  alfonder/torrentmonitor
```

В этом примере:
- обновление выполняется в `15` минут каждого часа с `8:00` до `23:00`;
- задан часовой пояс Москвы и синхронизировано время;
- файлы создаются от имени пользователя с UID `1001` и GID `1000`.

---

## Управление контейнером

```bash
docker container stop torrentmonitor       # остановить
docker container start torrentmonitor      # запустить снова
docker container restart torrentmonitor    # перезапустить
docker container logs -f torrentmonitor    # логи в реальном времени
docker container rm -f torrentmonitor      # удалить контейнер (данные в томах сохранятся)
```

---

## Изменить параметры уже запущенного контейнера

Параметры `docker run` (порты, переменные, тома) **нельзя** поменять «на лету». Нужно пересоздать
контейнер — данные при этом сохранятся в томах:

```bash
docker container rm -f torrentmonitor
docker container run -d ... alfonder/torrentmonitor   # с новыми параметрами
```

Именно поэтому для постоянной эксплуатации удобнее
**[Docker Compose](Run-with-Docker-Compose)** — там достаточно отредактировать YAML-файл.

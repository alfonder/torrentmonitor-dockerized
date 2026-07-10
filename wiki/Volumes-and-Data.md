# Тома и постоянные данные

Контейнеры по своей природе одноразовые: при удалении контейнера всё, что хранилось внутри,
пропадает. Чтобы база данных и скачанные `.torrent`-файлы **сохранялись**, их выносят в тома
(volumes) или в папки хоста.

---

## Внутренние пути контейнера

| Путь в контейнере | Что хранит | Обязательно сохранять |
| --- | --- | --- |
| `/data/htdocs/db` | База данных SQLite (`tm.sqlite`) и файл настроек (`config.xml`) | ✅ Да |
| `/data/htdocs/torrents` | Скачанные `.torrent`-файлы | ✅ Да |
| `/data/htdocs/logs` | Логи приложения (опционально) | желательно |

Образ объявляет тома для `/data/htdocs/db` и `/data/htdocs/torrents` — это самые важные данные.
Если их не примонтировать явно, Docker создаст анонимные тома, которые легко потерять. **Всегда**
монтируйте эти пути явно.

---

## Два способа хранения

### 1. Именованные тома (управляются Docker)

Docker сам хранит данные в своей служебной области. Удобно и переносимо.

```bash
docker volume create torrentfiles
docker volume create db

docker container run -d \
  --name torrentmonitor \
  -p 8080:80 \
  -v torrentfiles:/data/htdocs/torrents \
  -v db:/data/htdocs/db \
  alfonder/torrentmonitor
```

Где физически лежат данные:

```bash
docker volume inspect db        # поле "Mountpoint" покажет путь на хосте
```

### 2. Папки хоста (bind mount)

Данные лежат в обычных папках, которые вы видите в файловой системе. Удобно для бэкапов и ручного
доступа к файлам.

```bash
mkdir -p /opt/torrentmonitor/torrents /opt/torrentmonitor/db

docker container run -d \
  --name torrentmonitor \
  -p 8080:80 \
  -v /opt/torrentmonitor/torrents:/data/htdocs/torrents \
  -v /opt/torrentmonitor/db:/data/htdocs/db \
  alfonder/torrentmonitor
```

> При использовании папок хоста часто нужно задать **[PUID/PGID](Environment-Variables#puid-и-pgid--права-на-файлы)**,
> чтобы файлы принадлежали вашему пользователю.

---

## Тома в Docker Compose

```yaml
services:
  torrentmonitor:
    image: alfonder/torrentmonitor:latest
    volumes:
      # Папки хоста рядом с docker-compose.yml:
      - ./torrents:/data/htdocs/torrents
      - ./db:/data/htdocs/db
      - ./logs:/data/htdocs/logs
      - /etc/localtime:/etc/localtime:ro
```

Или с именованными томами:

```yaml
services:
  torrentmonitor:
    image: alfonder/torrentmonitor:latest
    volumes:
      - torrentfiles:/data/htdocs/torrents
      - db:/data/htdocs/db

volumes:
  torrentfiles:
  db:
```

---

## Резервное копирование

### Папки хоста

Просто скопируйте папки:

```bash
tar czf torrentmonitor-backup-$(date +%F).tar.gz -C /opt/torrentmonitor db torrents
```

### Именованные тома

Самое важное — база данных. Скопировать её из тома:

```bash
docker run --rm \
  -v db:/data \
  -v "$(pwd)":/backup \
  alpine tar czf /backup/tm-db-backup.tar.gz -C /data .
```

Восстановление:

```bash
docker run --rm \
  -v db:/data \
  -v "$(pwd)":/backup \
  alpine sh -c "cd /data && tar xzf /backup/tm-db-backup.tar.gz"
```

> 💾 Перед обновлением образа или экспериментами обязательно делайте бэкап папки `db` — там вся
> ваша конфигурация и список отслеживаемых раздач.

---

## Можно ли удалять контейнер?

Да. Если данные вынесены в тома или папки хоста, контейнер можно безопасно удалять и пересоздавать —
данные не пострадают:

```bash
docker container rm -f torrentmonitor
docker container run -d ... alfonder/torrentmonitor   # тот же том db — те же данные
```

Удаление **именованного тома** (`docker volume rm db`) или папки хоста — вот это удаляет данные
безвозвратно. Будьте внимательны.

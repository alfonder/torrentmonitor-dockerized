# Тома и постоянные данные

Контейнеры по своей природе одноразовые: при удалении контейнера всё, что хранилось внутри,
пропадает. Чтобы данные приложения и скачанные `.torrent`-файлы **сохранялись**, их выносят в тома
(volumes) или в папки хоста.

---

## Внутренние пути контейнера

| Путь в контейнере | Что хранит | Обязательно сохранять |
| --- | --- | --- |
| `/data/htdocs/db` | Каталог данных TorrentMonitor: JSON-файлы с темами, учётными данными трекеров и настройками | ✅ Да |
| `/data/htdocs/torrents` | Скачанные `.torrent`-файлы | ✅ Да |
| `/data/htdocs/logs` | Больше не используется | нет |

Образ объявляет тома для `/data/htdocs/db` и `/data/htdocs/torrents` — это самые важные данные.
Если их не примонтировать явно, Docker создаст анонимные тома, которые легко потерять. **Всегда**
монтируйте эти пути явно.

В `/data/htdocs/logs` TorrentMonitor 4 ничего не пишет. Если эта папка примонтирована в вашем
compose-файле, строку можно убрать; если оставить — ничего не сломается. Журнал проверок теперь
лежит в каталоге данных (`engine.log`).

---

## Что лежит в `/data/htdocs/db`

Базы данных в TorrentMonitor 4 нет. Путь тома остался прежним, поэтому тома и compose-файлы
прежних версий менять не нужно.

| Файл | Что это |
| --- | --- |
| `config.json` | Настройки, учётные данные трекеров и торрент-клиента |
| `torrents.json` | Отслеживаемые темы |
| `state.json` | Состояние проверок |
| `engine.log` | Журнал последней проверки |
| `*.bak` | Предыдущая версия файла, её создаёт сам TorrentMonitor |
| `*.lock` | Служебные файлы блокировки |
| `tm.sqlite`, `config.xml`, `db_crypt.key` | Файлы версии 3.x. Остаются после перехода как копия и больше не используются |

> 🔐 Пароли трекеров и торрент-клиента записаны в `config.json` **в открытом виде**. Файл создаётся
> с правами `600`, но это не шифрование: любой, кто может прочитать том или его резервную копию,
> увидит пароли. Не давайте доступ к папке `db` посторонним и не выкладывайте её копии.

О файлах версии 3.x — на странице
**[Обновление и обслуживание](Updating-and-Maintenance#переход-с-версии-3x-на-torrentmonitor-40)**.

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

Самое важное — том `db`. Скопировать его содержимое:

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

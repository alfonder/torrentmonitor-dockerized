# TorrentMonitor + TOR + Transmission

Некоторые трекеры (например rutracker.org) могут быть недоступны напрямую из-за блокировок.
Связка из трёх контейнеров решает это:

- **TOR** — выступает HTTP/SOCKS-прокси и даёт доступ к заблокированным трекерам;
- **TorrentMonitor** — следит за раздачами через прокси TOR и передаёт `.torrent` в клиент;
- **Transmission** — собственно скачивает торренты.

> ℹ️ TOR используется только для **доступа к страницам трекеров и скачивания `.torrent`-файлов**
> (это лёгкий трафик). Сами торренты качает Transmission напрямую — гонять торрент-трафик через TOR
> нельзя.

---

## Пример `docker-compose.yml`

```yaml
services:
  tor:
    container_name: tor
    image: dperson/torproxy
    restart: unless-stopped
    # Внутри сети compose сервис доступен по имени host "tor":
    #   HTTP-прокси  -> tor:8118
    #   SOCKS-прокси -> tor:9050

  transmission:
    container_name: transmission
    image: linuxserver/transmission
    restart: unless-stopped
    ports:
      - "9091:9091"        # Web UI Transmission
      - "51413:51413"      # порт обмена торрент-трафиком (TCP)
      - "51413:51413/udp"  # порт обмена торрент-трафиком (UDP)
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
    volumes:
      - ./transmission/config:/config
      - ./downloads:/downloads
      - ./watch:/watch       # папка, за которой следит Transmission

  torrentmonitor:
    container_name: torrentmonitor
    image: alfonder/torrentmonitor:latest
    restart: unless-stopped
    depends_on:
      - tor
      - transmission
    ports:
      - "8080:80"
    volumes:
      - ./torrentmonitor/torrents:/data/htdocs/torrents
      - ./torrentmonitor/db:/data/htdocs/db
      - /etc/localtime:/etc/localtime:ro
    environment:
      - PHP_TIMEZONE=Europe/Moscow
      - CRON_TIMEOUT=*/30 8-22 * * *
```

Запуск всей связки:

```bash
docker compose up -d
```

---

## Настройка связки

### 1. TOR

Контейнер `tor` поднимает HTTP-прокси на порту `8118` и SOCKS5 на `9050`. Внутри сети Docker Compose
он доступен другим контейнерам по имени хоста `tor` (например `tor:8118`).

### 2. TorrentMonitor → доступ через TOR

В веб-интерфейсе TorrentMonitor откройте **Настройки → Сеть**, отметьте «Обращаться к трекерам
через прокси» и укажите:

```
Адрес прокси: tor:8118
Тип прокси:   HTTP
```

Если прокси нужен только одному трекеру, задайте его не здесь, а в разделе «Трекеры» — в поле
«Прокси» в форме этого трекера.

Теперь TorrentMonitor будет открывать страницы трекеров и скачивать `.torrent` через TOR, обходя
блокировки.

### 3. TorrentMonitor → Transmission

В **Настройки → Torrent-клиенты** добавьте клиент вида Transmission:

```
адрес: http://transmission:9091
логин/пароль: как настроено в Transmission (RPC)
```

TorrentMonitor будет передавать новые раздачи прямо в Transmission на скачивание. Transmission
получает сам `.torrent`-файл, поэтому доступ от него к контейнеру TorrentMonitor не нужен.

---

## Проверка

```bash
docker compose ps                    # все три контейнера должны быть Up
docker compose logs -f torrentmonitor
```

- Web UI TorrentMonitor: <http://localhost:8080>
- Web UI Transmission: <http://localhost:9091>

Проверить, что TOR работает, можно прямо из контейнера TorrentMonitor:

```bash
docker exec torrentmonitor sh -c "wget -qO- -e use_proxy=yes -e http_proxy=http://tor:8118 https://check.torproject.org/api/ip"
```

В ответе должно быть `"IsTor": true`.

---

## Примечания

- Образы `dperson/torproxy`, `linuxserver/transmission` приведены как рабочий пример — можно
  заменить на любые аналоги.
- Скорость доступа через TOR ниже обычной — это нормально, ведь через него идёт только лёгкий
  трафик (HTML-страницы и `.torrent`-файлы).
- Если конкретный трекер не открывается даже через TOR, попробуйте другой адрес (зеркало) трекера —
  поле «Адрес» в форме трекера в разделе «Трекеры».

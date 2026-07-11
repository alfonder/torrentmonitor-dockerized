# Решение проблем

Частые проблемы и способы их устранения. Первым делом всегда смотрите логи:

```bash
docker container logs -f torrentmonitor
```

---

## Контейнер не запускается / сразу падает

- **Неверный `NGINX_PORT`.** Значение должно быть числом от 1 до 65535. При неверном значении
  контейнер останавливается с сообщением в логе. Исправьте переменную
  **[NGINX_PORT](Environment-Variables#nginx_port--внутренний-порт)**.
- **Порт уже занят на хосте.** Ошибка вида `port is already allocated`. Поменяйте левую часть в
  `-p`, например `-p 8081:80`.
- Посмотрите причину:

  ```bash
  docker container logs torrentmonitor
  docker container inspect torrentmonitor -f '{{ .State.Status }} {{ .State.Error }}'
  ```

---

## Веб-интерфейс не открывается

- Проверьте, что контейнер запущен: `docker ps` (статус должен быть `Up`).
- Проверьте проброс портов: в `docker ps` колонка `PORTS` должна показывать `0.0.0.0:8080->80/tcp`.
- Открываете с другого устройства? Используйте IP сервера, а не `localhost`, и убедитесь, что порт
  не закрыт фаерволом.
- Если меняли `NGINX_PORT`, левая и правая части `-p` должны быть согласованы (см.
  **[Запуск через docker run](Run-with-docker-run#настройка-порта)**).

---

## Не скачиваются `.torrent` с трекера

- **Нет авторизации на трекере.** Для приватных трекеров (rutracker.org и др.) укажите логин/пароль
  трекера в настройках раздачи.
- **Трекер заблокирован.** Настройте доступ через прокси — см.
  **[TorrentMonitor + TOR + Transmission](TOR-and-Transmission)**.
- **Капча / защита трекера.** Иногда трекер требует ручного входа; проверьте учётные данные и
  доступность сайта.

---

## Обновления не проверяются по расписанию

- Проверьте формат **[CRON_TIMEOUT](Environment-Variables#cron_timeout--расписание-проверок)** —
  это пять полей cron.
- Убедитесь, что часовой пояс **[PHP_TIMEZONE](Environment-Variables#php_timezone--часовой-пояс)**
  задан верно — расписание привязано к нему.
- Запустите проверку вручную и посмотрите вывод:

  ```bash
  docker exec torrentmonitor php -q /data/htdocs/engine.php
  ```

---

## Ошибки нехватки памяти

При обработке большого числа раздач PHP может упереться в лимит памяти. Увеличьте
**[PHP_MEMORY_LIMIT](Environment-Variables#php_memory_limit--лимит-памяти)**:

```bash
-e PHP_MEMORY_LIMIT="1024M"
```

---

## Проблемы с правами на файлы

Если файлы в примонтированных папках создаются с неподходящим владельцем (например, недоступны
Sonarr/Transmission), задайте
**[PUID/PGID](Environment-Variables#puid-и-pgid--права-на-файлы)**, совпадающие с вашим пользователем:

```bash
-e PUID=$(id -u) -e PGID=$(id -g)
```

---

## Неправильное время в интерфейсе

- Задайте **[PHP_TIMEZONE](Environment-Variables#php_timezone--часовой-пояс)**.
- Дополнительно примонтируйте системное время хоста:

  ```bash
  -v /etc/localtime:/etc/localtime:ro
  ```

---

## Потерялись данные после пересоздания контейнера

Скорее всего, тома не были примонтированы явно, и Docker использовал анонимные тома. Всегда
монтируйте `/data/htdocs/db` и `/data/htdocs/torrents` явно — см.
**[Тома и постоянные данные](Volumes-and-Data)**.

---

## Доступ внутрь контейнера для диагностики

```bash
docker exec -it torrentmonitor sh
```

Полезные команды внутри:

```bash
ls -la /data/htdocs/db          # база и настройки на месте?
cat /etc/crontabs/nginx         # какое расписание установлено
php -v                          # версия PHP
```

---

## Ничего не помогло?

Соберите информацию и заведите issue в репозитории:

```bash
docker container logs --tail 200 torrentmonitor
docker container inspect torrentmonitor
docker version
```

👉 [Issues проекта](https://github.com/alfonder/torrentmonitor-dockerized/issues)

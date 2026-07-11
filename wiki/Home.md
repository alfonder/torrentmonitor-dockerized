# TorrentMonitor в Docker — Вики

Добро пожаловать в документацию проекта **TorrentMonitor Dockerized** — контейнера Docker для
[TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor), веб-приложения для
отслеживания и автоматической загрузки торрентов с различных трекеров.

Этот раздел вики содержит подробные пошаговые инструкции с примерами: от установки Docker
до тонкой настройки контейнера и связки с TOR + Transmission.

> 📌 Если вам нужна краткая справка — смотрите [README](https://github.com/alfonder/torrentmonitor-dockerized/blob/master/README.md).
> Эта вики предназначена для подробного изучения.

> 📖 Здесь описан только **Docker-контейнер**. Документация самого приложения TorrentMonitor —
> веб-интерфейс, настройки, поддерживаемые трекеры, торрент-клиенты, уведомления — находится в
> **[Вики TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor/wiki)**.

---

## С чего начать

Если вы здесь впервые, пройдите по шагам:

1. **[Установка Docker](Installing-Docker)** — установка Docker на Linux, Windows и macOS.
2. **[Быстрый старт](Quick-Start)** — запуск контейнера за 5 минут.
3. **[Настройка и использование](Configuration-and-Usage)** — первый вход в веб-интерфейс и работа с приложением.

---

## Содержание

### Установка и запуск
- **[Установка Docker](Installing-Docker)** — все способы установить Docker.
- **[Запуск на NAS (Synology, QNAP)](NAS-Synology-QNAP)** — есть ли Docker на вашем NAS и как быть, если его нет.
- **[Быстрый старт](Quick-Start)** — минимальный рабочий пример.
- **[Запуск через `docker run`](Run-with-docker-run)** — подробно про запуск одной командой.
- **[Запуск через Docker Compose](Run-with-Docker-Compose)** — рекомендуемый способ для постоянной эксплуатации.

### Конфигурация
- **[Переменные окружения](Environment-Variables)** — полный справочник всех переменных.
- **[Тома и постоянные данные](Volumes-and-Data)** — как не потерять базу и торренты.
- **[Настройка и использование](Configuration-and-Usage)** — первый вход, подключение клиентов из контейнера, расписание.

### Сценарии использования
- **[TorrentMonitor + TOR + Transmission](TOR-and-Transmission)** — обход блокировок трекеров.

### Эксплуатация
- **[Обновление и обслуживание](Updating-and-Maintenance)** — обновление образа, бэкапы, логи.
- **[Решение проблем](Troubleshooting)** — частые ошибки и их решения.
- **[Платформы, теги и версии](Platforms-Tags-and-Versions)** — поддерживаемые архитектуры и теги образов.

---

## Что такое TorrentMonitor

TorrentMonitor — это веб-приложение на PHP, которое:

- следит за страницами раздач на торрент-трекерах;
- обнаруживает обновления (новые серии, новые версии раздач, изменения в группах релизов);
- автоматически скачивает свежие `.torrent`-файлы или передаёт их в торрент-клиент
  (Transmission, qBittorrent, Deluge и др.);
- работает по расписанию (cron) внутри контейнера.

Контейнер собран на базе **Alpine Linux** с **Nginx** и **PHP 8.5**.

Список поддерживаемых трекеров и подробности о возможностях приложения — в
**[Вики TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor/wiki)**.

---

## Благодарности

Особая благодарность [Евгению Елизарову](https://github.com/ElizarovEugene) за само приложение
[TorrentMonitor](https://github.com/ElizarovEugene/TorrentMonitor). Спасибо [nawa](https://github.com/nawa)
за исходный проект [`torrentmonitor-dockerized`](https://github.com/nawa/torrentmonitor-dockerized).

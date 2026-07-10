# Платформы, теги и версии

---

## Поддерживаемые платформы

Образ собирается как multi-arch — Docker сам выбирает нужный вариант под вашу архитектуру.
Текущие собираемые платформы:

| Архитектура | Описание и примеры устройств |
| --- | --- |
| **amd64** (x86-64) | 64-битные Intel/AMD — большинство ПК и серверов |
| **arm64** (aarch64) | 64-битные ARM — Raspberry Pi 4/5, Apple Silicon Mac (через Docker Desktop), AWS Graviton, NVIDIA Jetson, ODROID-N2+, Orange Pi 5, Rock Pi 4, Banana Pi M5 |
| **arm/v7** (arm32v7) | 32-битные ARMv7 — Raspberry Pi 2/3, Pi Zero 2 W, BeagleBone Black, ODROID-XU4, ASUS Tinker Board, Orange Pi PC, NanoPi NEO |
| **arm/v6** (arm32v6) | 32-битные ARMv6 — Raspberry Pi 1 A/B, Pi Zero / Zero W, Compute Module 1 |
| **riscv64** | 64-битные RISC-V — SiFive, StarFive VisionFive, платы Allwinner D1 |

> Устаревшие и более не собираемые платформы: `x86` (32-бит Intel/AMD), `ppc64le` (IBM POWER),
> `s390x` (IBM Z). Другие платформы могут быть добавлены по запросу через
> [issue](https://github.com/alfonder/torrentmonitor-dockerized/issues).

---

## Теги образов

| Тег | Что это |
| --- | --- |
| `latest` | Самая свежая версия на актуальном Alpine Linux. **Рекомендуется.** |
| `vXXXX-X` | Конкретная версия TorrentMonitor и номер сборки (для фиксации версии). |
| `legacy` | Старая стабильная версия на Alpine 3.15 и PHP 7. |
| `devel` | Версия для отладки. **Не рекомендуется** для обычного использования. |

Использование конкретного тега:

```bash
docker pull alfonder/torrentmonitor:latest
docker pull alfonder/torrentmonitor:legacy
```

В Docker Compose тег задаётся в `image:`:

```yaml
image: alfonder/torrentmonitor:latest
```

---

## Реестры образов

Образ публикуется в двух реестрах — используйте любой:

```bash
# Docker Hub
docker pull alfonder/torrentmonitor:latest

# GitHub Container Registry
docker pull ghcr.io/alfonder/torrentmonitor:latest
```

---

## Из чего собран образ

- **Базовый образ:** Alpine Linux
- **Веб-сервер:** Nginx
- **PHP:** 8.5 (в теге `legacy` — PHP 7)
- **База данных:** SQLite (хранится в томе `/data/htdocs/db`)

---

## Поддержка ОС

**Linux** — используйте Docker Engine напрямую, нужный образ подберётся автоматически.

**Windows и macOS** — используйте Docker Desktop. Подробности установки — на странице
**[Установка Docker](Installing-Docker)**.

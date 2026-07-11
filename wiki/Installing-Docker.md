# Установка Docker

Перед запуском TorrentMonitor нужно установить Docker. Ниже — инструкции для разных операционных систем.

> 💡 **Какой Docker нужен?** Для серверов и домашних NAS на Linux достаточно **Docker Engine**.
> Для рабочих станций на Windows и macOS используется **Docker Desktop**.

> 📦 **У вас Synology или QNAP?** Там Docker ставится не из консоли, а отдельным приложением
> (Container Manager / Container Station) — и поддерживается **не на всех** моделях. Что делать в этом
> случае, см. на странице **[Запуск на NAS (Synology, QNAP)](NAS-Synology-QNAP)**.

---

## Содержание
- [Linux (Docker Engine)](#linux-docker-engine)
- [Windows (Docker Desktop)](#windows-docker-desktop)
- [macOS (Docker Desktop)](#macos-docker-desktop)
- [Запуск без sudo (группа docker)](#запуск-без-sudo-группа-docker)
- [Установка Docker Compose](#установка-docker-compose)
- [Проверка установки](#проверка-установки)

---

## Linux (Docker Engine)

Официальная инструкция: <https://docs.docker.com/engine/install/>

### Быстрая установка (универсальный скрипт)

Подходит для большинства дистрибутивов (Ubuntu, Debian, Fedora, CentOS и др.):

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Ubuntu / Debian — из репозитория дистрибутива (`docker.io`)

Самый простой способ: пакет `docker.io` уже есть в стандартных репозиториях Ubuntu и Debian, ставится
одной командой и обновляется вместе с системой через `apt`.

```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
```

Плагин Docker Compose v2 в этом случае ставится отдельным пакетом:

```bash
sudo apt-get install -y docker-compose-v2
```

> ⚠️ В репозиториях дистрибутива версия Docker обычно немного старее, чем в официальном репозитории
> Docker. Для домашнего сервера и NAS этого, как правило, более чем достаточно. Если нужна самая
> свежая версия — используйте официальный репозиторий Docker (ниже).

### Ubuntu / Debian — через официальный репозиторий Docker

Этот способ даёт самую свежую версию Docker напрямую от Docker, Inc.

```bash
# 1. Удалите старые пакеты, если они были
sudo apt-get remove docker docker-engine docker.io containerd runc 2>/dev/null

# 2. Установите зависимости и ключ репозитория
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Подключите репозиторий
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Установите Docker Engine и плагин Compose
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> Для Debian замените `ubuntu` на `debian` в командах выше.

### Включить автозапуск службы Docker

```bash
sudo systemctl enable --now docker
```

---

## Windows (Docker Desktop)

1. Скачайте установщик: <https://www.docker.com/products/docker-desktop>
2. Требования: **Windows 10/11 64-bit** с включённым **WSL 2** (рекомендуется) или Hyper-V.
3. Запустите установщик и следуйте мастеру. При запросе включите бэкенд **WSL 2**.
4. После перезагрузки запустите Docker Desktop и дождитесь статуса **Running**.

Все команды `docker` из этой вики выполняются в **PowerShell** или в терминале WSL.

> ⚠️ В путях к томам Windows используйте формат `C:\путь\к\папке` или `/c/путь/к/папке` (в WSL).

---

## macOS (Docker Desktop)

1. Скачайте установщик: <https://www.docker.com/products/docker-desktop>
2. Выберите версию под ваш процессор:
   - **Apple Silicon (M1/M2/M3/M4)** — Apple chip;
   - **Intel** — Intel chip.
3. Перетащите Docker в папку «Программы» и запустите.
4. Дождитесь статуса **Running** в строке меню.

Команды `docker` выполняются в стандартном **Terminal** или iTerm.

---

## Запуск без sudo (группа docker)

На Linux по умолчанию команды Docker требуют `sudo`. Чтобы запускать их от своего пользователя,
добавьте себя в группу `docker`:

```bash
sudo groupadd docker            # обычно группа уже существует
sudo usermod -aG docker $USER   # добавить текущего пользователя
newgrp docker                   # применить без перезахода (или перелогиньтесь)
```

После этого можно вызывать `docker ...` без `sudo`.

> 🔒 Членство в группе `docker` фактически даёт права root. Добавляйте только доверенных пользователей.

---

## Установка Docker Compose

- **Docker Compose v2** (команда `docker compose`, через пробел) поставляется как плагин и уже
  включён в современные сборки Docker Engine и Docker Desktop. Отдельно ставить ничего не нужно.
- **Классический Docker Compose** (команда `docker-compose`, через дефис) — устаревшая отдельная
  утилита. При необходимости:

  ```bash
  sudo apt-get install -y docker-compose      # из репозитория дистрибутива
  ```

В этой вики поддерживаются оба варианта. Рекомендуется использовать `docker compose` (v2).

---

## Проверка установки

```bash
docker --version
docker compose version
docker run --rm hello-world
```

Если последняя команда вывела приветственное сообщение «Hello from Docker!» — установка прошла успешно,
и можно переходить к разделу **[Быстрый старт](Quick-Start)**.

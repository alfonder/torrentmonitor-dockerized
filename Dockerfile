# rootfs builder
FROM alpine:3.24.1 AS rootfs-builder

# TorrentMonitor release to install. TM_SOURCE may also be a file inside the build context
# (for example a locally built archive): --build-arg TM_SOURCE=TorrentMonitor-4.0.0.zip
ARG TM_VERSION="4.0.0-beta2"
ARG TM_SOURCE="https://github.com/azinchen/TorrentMonitor/releases/download/v${TM_VERSION}/TorrentMonitor-${TM_VERSION}.zip"

COPY rootfs/ /rootfs/
ADD ${TM_SOURCE} /tmp/tm.zip

RUN apk --no-cache add unzip && \
    unzip -q /tmp/tm.zip -d /tmp/tm && \
    cp -a /tmp/tm/TorrentMonitor-*/. /rootfs/data/htdocs/ && \
    test -f /rootfs/data/htdocs/public/index.php && \
    test -f /rootfs/data/htdocs/tools/convert-db.php

# Main image
FROM alpine:3.24.1

# Build arguments for TorrentMonitor Dockerized version tracking
ARG DOCKERIZED_VERSION="dev"
ARG BUILD_DATE="unknown"

ENV TM_VERSION="4.0.0-beta2" \
    TM_RELEASE_DATE="23.11.2026" \
    CRON_TIMEOUT="0 * * * *" \
    CRON_COMMAND="php -q /data/htdocs/engine.php 2>&1" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    NGINX_PORT="80"

LABEL org.opencontainers.image.authors="Alexander Fomichev <fomichev.ru@gmail.com>" \
    org.opencontainers.image.title="TorrentMonitor Dockerized" \
    org.opencontainers.image.description="Dockerized TorrentMonitor v${TM_VERSION} with Alpine Linux, Nginx and PHP 8.5" \
    org.opencontainers.image.source="https://github.com/alfonder/torrentmonitor-dockerized" \
    org.opencontainers.image.url="https://github.com/alfonder/torrentmonitor-dockerized" \
    org.opencontainers.image.version="${DOCKERIZED_VERSION}" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    torrentmonitor.app.version="${TM_VERSION}" \
    torrentmonitor.app.release-date="${TM_RELEASE_DATE}" \
    torrentmonitor.app.url="https://github.com/azinchen/TorrentMonitor" \
    torrentmonitor.app.source="https://github.com/azinchen/TorrentMonitor"

COPY --from=rootfs-builder /rootfs/ /

RUN apk --no-cache add \
        nginx \
        wget \
        shadow \
        php85 \
        php85-common \
        php85-fpm \
        php85-curl \
        php85-sqlite3 \
        php85-pdo_sqlite \
        php85-xml \
        php85-simplexml \
        php85-session \
        php85-mbstring \
        php85-ctype \
        php85-zip \
        php85-dom \
        php85-openssl \
        && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -T 5 -O /dev/null http://127.0.0.1/healthz || exit 1

ENTRYPOINT ["/init"]

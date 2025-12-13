# apk builder (build gnu-libiconv 1.15 from source)
FROM alpine:3.23.2 AS apk-builder

RUN apk --no-cache add \
        alpine-sdk \
        sudo \
        wget \
        && \
    adduser -D builduser && \
    addgroup builduser abuild && \
    addgroup builduser wheel && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel && \
    chmod 0400 /etc/sudoers.d/wheel

USER builduser
WORKDIR /home/builduser

RUN abuild-keygen -an -i -q && \
    wget -O APKBUILD "https://gitlab.alpinelinux.org/alpine/aports/-/raw/3.13-stable/community/gnu-libiconv/APKBUILD" && \
    abuild checksum && \
    abuild deps && \
    abuild fetch && \
    abuild unpack && \
    sed -i '39,48d' src/libiconv-1.15/lib/loop_wchar.h && \
    abuild build && \
    abuild rootpkg

# rootfs builder
FROM alpine:3.23.2 AS rootfs-builder

COPY rootfs/ /rootfs/
COPY patches/ /tmp/
ADD https://github.com/ElizarovEugene/TorrentMonitor/archive/refs/heads/master.zip /tmp/tm-latest.zip

RUN apk --no-cache add \
        unzip \
        sqlite \
        patch \
        && \
    unzip /tmp/tm-latest.zip -d /tmp/ && \
    mv /tmp/TorrentMonitor-master/* /rootfs/data/htdocs && \
    cat /rootfs/data/htdocs/db_schema/sqlite.sql | sqlite3 /rootfs/data/htdocs/db_schema/tm.sqlite

# Main image
FROM alpine:3.23.2

# Build arguments for TorrentMonitor Dockerized version tracking
ARG DOCKERIZED_VERSION="dev"
ARG BUILD_DATE="unknown"

ENV TM_VERSION="2.2.3" \
    TM_RELEASE_DATE="16.02.2026" \
    CRON_TIMEOUT="0 * * * *" \
    CRON_COMMAND="php -q /data/htdocs/engine.php 2>&1" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    NGINX_PORT="80" \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so"

LABEL org.opencontainers.image.authors="Alexander Fomichev <fomichev.ru@gmail.com>" \
    org.opencontainers.image.title="TorrentMonitor Dockerized" \
    org.opencontainers.image.description="Dockerized TorrentMonitor v${TM_VERSION} with Alpine Linux, Nginx and PHP 8.5" \
    org.opencontainers.image.source="https://github.com/alfonder/torrentmonitor-dockerized" \
    org.opencontainers.image.url="https://github.com/alfonder/torrentmonitor-dockerized" \
    org.opencontainers.image.version="${DOCKERIZED_VERSION}" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    torrentmonitor.app.version="${TM_VERSION}" \
    torrentmonitor.app.release-date="${TM_RELEASE_DATE}" \
    torrentmonitor.app.url="https://tormon.ru" \
    torrentmonitor.app.source="https://github.com/ElizarovEugene/TorrentMonitor"

COPY --from=rootfs-builder /rootfs/ /
COPY --from=apk-builder /home/builduser/packages /tmp/packages

RUN apk --no-cache add \
        nginx \
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
        php85-iconv \
        php85-mbstring \
        php85-ctype \
        php85-zip \
        php85-dom \
        && \
    apk --allow-untrusted add /tmp/packages/home/*/gnu-libiconv-1.15-r3.apk && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80

ENTRYPOINT ["/init"]

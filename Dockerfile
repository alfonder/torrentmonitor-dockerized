# rootfs builder
FROM alpine:3.20.3 as rootfs-builder

COPY rootfs/ /rootfs/
COPY patches/ /tmp/
ADD https://tormon.ru/tm-latest.zip /tmp/tm-latest.zip

RUN apk --no-cache add \
        unzip \
        sqlite \
        patch \
        && \
    unzip /tmp/tm-latest.zip -d /tmp/ && \
    mv /tmp/TorrentMonitor-master/* /rootfs/data/htdocs && \
    cat /rootfs/data/htdocs/db_schema/sqlite.sql | sqlite3 /rootfs/data/htdocs/db_schema/tm.sqlite

# Main image
FROM alpine:3.20.3
MAINTAINER Alexander Fomichev <fomichev.ru@gmail.com>
LABEL org.opencontainers.image.source="https://github.com/alfonder/torrentmonitor-dockerized/"

ENV VERSION="2.1.4" \
    RELEASE_DATE="26.10.2024" \
    CRON_TIMEOUT="0 * * * *" \
    CRON_COMMAND="php -q /data/htdocs/engine.php 2>&1" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so"

COPY --from=rootfs-builder /rootfs/ /

RUN apk --no-cache add \
        nginx \
        shadow \
        php83 \
        php83-common \
        php83-fpm \
        php83-curl \
        php83-sqlite3 \
        php83-pdo_sqlite \
        php83-xml \
        php83-simplexml \
        php83-session \
        php83-iconv \
        php83-mbstring \
        php83-ctype \
        php83-zip \
        php83-dom \
        && \
    apk add gnu-libiconv=1.15-r3 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ ; \
    test -f /usr/bin/php-fpm || ln -s /usr/sbin/php-fpm83 /usr/bin/php-fpm ; \
    test -f /usr/bin/php || ln -s /usr/bin/php83 /usr/bin/php ; \
    test -e /etc/php || ln -s /etc/php83 /etc/php

LABEL ru.korphome.version="${VERSION}" \
      ru.korphome.release-date="${RELEASE_DATE}"

VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80

ENTRYPOINT ["/init"]

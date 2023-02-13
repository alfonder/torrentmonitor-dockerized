# rootfs builder
FROM alpine:3.15.6 as rootfs-builder

COPY rootfs/ /rootfs/
COPY patches/ /tmp/
ADD http://tormon.ru/tm-latest.zip /tmp/tm-latest.zip

RUN apk --no-cache add \
        unzip \
        sqlite \
        patch \
        && \
    unzip /tmp/tm-latest.zip -d /tmp/ && \
    mv /tmp/TorrentMonitor-master/* /rootfs/data/htdocs && \
    cat /rootfs/data/htdocs/db_schema/sqlite.sql | sqlite3 /rootfs/data/htdocs/db_schema/tm.sqlite && \
    mkdir -p /rootfs/var/log/nginx/

# Main image
FROM alpine:3.15.6
MAINTAINER Alexander Fomichev <fomichev.ru@gmail.com>

ENV VERSION="2.0.3" \
    RELEASE_DATE="" \
    CRON_TIMEOUT="0 * * * *" \
    CRON_COMMAND="php -q /data/htdocs/engine.php >> /var/log/tm-autorun.log 2>&1" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    PHP_DISPLAY_ERRORS="Off"

COPY --from=rootfs-builder /rootfs/ /

RUN apk --no-cache add \
        nginx \
        shadow \
        php7 \
        php7-common \
        php7-fpm \
        php7-curl \
        php7-sqlite3 \
        php7-pdo_sqlite \
        php7-xml \
        php7-json \
        php7-simplexml \
        php7-session \
        php7-iconv \
        php7-mbstring \
        php7-ctype \
        php7-zip \
        php7-dom \
        && \
    apk add gnu-libiconv=1.15-r3 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ && \
    ln -sf /dev/stdout /var/log/tm-autorun.log && \
    ln -sf /dev/stderr /var/log/php-fpm.log

LABEL ru.korphome.version="${VERSION}" \
      ru.korphome.release-date="${RELEASE_DATE}"

VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80

ENTRYPOINT ["/init"]

# to do
# -1. PUID/PGID
# 2. php variables
# 3. php conf update script
# -4. php.ini correct
# -5. openrc 
# -6. logs


#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM alpine:3.8
MAINTAINER Siarhei Navatski <navatski@gmail.com>, Andrey Aleksandrov <alex.demion@gmail.com>, Alexander Fomichev <fomichev.ru@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.8.7" \
    RELEASE_DATE="16.06.2021" \
    CRON_TIMEOUT="0 * * * *" \
    CRON_COMMAND="php -q /data/htdocs/engine.php >> /var/log/nginx/torrentmonitor_cron_error.log 2>\&1" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    LD_PRELOAD="/usr/local/lib/preloadable_libiconv.so"

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------
ADD rootfs /

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------
RUN apk update \
    && apk upgrade \
    && apk --no-cache add --update -t deps wget unzip sqlite build-base tar re2c make file curl \
    && apk --no-cache add nginx php5-common php5-cli php5-fpm php5-curl php5-sqlite3 php5-pdo_sqlite php5-iconv php5-json php5-ctype php5-zip \
    && wget -q http://korphome.ru/torrent_monitor/tm-latest.zip -O /tmp/tm-latest.zip \
    && unzip /tmp/tm-latest.zip -d /tmp/ \
    && mv /tmp/TorrentMonitor-master/* /data/htdocs \
    && cat /data/htdocs/db_schema/sqlite.sql | sqlite3 /data/htdocs/db_schema/tm.sqlite \
    && mkdir -p /var/log/nginx/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && ln -sf /dev/stdout /var/log/php-fpm.log \
    && rm /usr/bin/iconv \
    && curl -SL http://ftpmirror.gnu.org/libiconv/libiconv-1.15.tar.gz | tar -xz -C /tmp \
    && cd /tmp/libiconv-1.15 \
    && ./configure --prefix=/usr/local \
    && make && make install \
    && apk del --purge deps; rm -rf /tmp/* /var/cache/apk/*

#------------------------------------------------------------------------------
# Set labels:
#------------------------------------------------------------------------------
LABEL ru.korphome.version="${VERSION}" \
      ru.korphome.release-date="${RELEASE_DATE}"

#------------------------------------------------------------------------------
# Set volumes, workdir, expose ports and entrypoint:
#------------------------------------------------------------------------------
VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80
ENTRYPOINT ["/init"]

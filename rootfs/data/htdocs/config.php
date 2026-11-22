<?php
// Settings of the Docker image: data and torrent files live in the mounted volumes.
// The data directory keeps its old path, so volumes of earlier versions keep working.
Config::write('data.dir', '/data/htdocs/db');
Config::write('torrents.dir', '/data/htdocs/torrents');

#!/bin/bash
set -euxo pipefail

# https://mariadb.com/kb/en/mysqldump/

mkdir -p /backup

while :
do
    mysqldump -uroot -hmariadb -p"$MYSQL_ROOT_PASSWORD" --skip-comments --default-character-set=utf8 --all-databases | gzip -6 > /backup/dump_$(date +%Y-%m-%d_%H-%M-%S).sql.gz
    find /backup -mtime +10 -type f -delete
    sleep 12h
done

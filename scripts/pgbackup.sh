#!/bin/bash
set -euxo pipefail

# https://www.postgresql.org/docs/current/app-pgdump.html

mkdir -p /backup

export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"

while :
do
    pg_dumpall --username postgres --host postgres --no-password --clean | gzip -6 > /backup/dump_$(date +%Y-%m-%d_%H-%M-%S).sql.gz
    find /backup -mtime +10 -type f -delete
    sleep 12h
done

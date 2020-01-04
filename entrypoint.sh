#!/bin/bash
set -euxo pipefail

chown -R www-data:www-data /app
cd /app

[ $# -lt 1 ] && exec apache2-foreground

sleep ${SLEEP:-0}

export COMPOSER_HOME=/app/.composer

# eval $@
su -s /bin/bash -l www-data -c "export COMPOSER_HOME=/app/.composer; cd /app; $*"

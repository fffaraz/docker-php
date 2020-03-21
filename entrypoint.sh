#!/bin/bash
set -euxo pipefail

if [ $# -lt 1 ]; then
    mkdir -p /app/public
    mkdir -p /app/dockerweb/tmp
    mkdir -p /app/dockerweb/log
    env > /app/dockerweb/envvars
    chown -R www-data:www-data /app
    #find /app -type d -exec chmod 0755 {} \;
    #find /app -type f -exec chmod 0644 {} \;
    if [ -f /app/composer.json ]; then
        echo "Found 'composer.json', installing dependencies ..."
        #TODO: composer install --no-interaction --no-ansi --optimize-autoloader
    fi
    exec apache2-foreground
else
    sleep ${SLEEP:-0}
    export COMPOSER_HOME=/app/.composer
    # eval "$@"
    su -s /bin/bash -l www-data -c "export COMPOSER_HOME=/app/.composer; cd /app; $*"
fi

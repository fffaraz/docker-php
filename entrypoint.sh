#!/bin/bash
set -euxo pipefail

# Environment variables
alias art='php artisan'
alias ll='ls -alh'
export TERM=xterm
export COMPOSER_HOME=/app/.composer

mkdir -p /app/public
mkdir -p /app/.dockerweb/tmp
mkdir -p /app/.dockerweb/log
env > /app/.dockerweb/envvars

chown -R www-data:www-data /app
#find /app -type d -exec chmod 0755 {} \;
#find /app -type f -exec chmod 0644 {} \;

if [[ -f /app/composer.json && ! -f /app/vendor/autoload.php ]]; then
    echo "Found 'composer.json', installing dependencies ..."
    #TODO: composer install --no-interaction --no-ansi --optimize-autoloader
fi

[ $# -lt 1 ] && exec apache2-foreground

sleep ${SLEEP:-0}
# eval "$@", exec "$@"
su -s /bin/bash -l www-data -c "export COMPOSER_HOME=/app/.composer; cd /app; $*"

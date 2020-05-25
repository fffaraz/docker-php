#!/bin/bash
set -euxo pipefail

#source /etc/profile

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

if [ "$1" == "ssh" ]; then
    echo "www-data:${SSHPASSWORD}" | chpasswd
    echo "root:${SSHPASSWORD}" | chpasswd
    exec /usr/sbin/sshd -D
fi

sleep ${SLEEP:-0}
# eval "$@" <or> exec "$@"
su -s /bin/bash -l www-data -c "cd /app; $*"

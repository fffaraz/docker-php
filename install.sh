#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get -yq update
apt-get -yq upgrade
apt-get -yq install \
            bash build-essential ca-certificates dnsutils git nano netbase unzip wget whois zip \
            curl libcurl4 libcurl4-openssl-dev openssl libmcrypt-dev libssl-dev \
            libfreetype6-dev libicu-dev libjpeg62-turbo-dev libonig-dev libpng-dev libjpeg-dev \
            mariadb-client libpq-dev libsqlite3-dev libbz2-dev zlib1g-dev libzip-dev \
            libmagickwand-dev \
            ghostscript # Ghostscript is required for rendering PDF previews

# TODO: postgresql-client default-mysql-client
# TODO: ttf-mscorefonts
# TODO: logrotate
# TODO: dropbear

#update-ca-certifcates
#wget https://curl.haxx.se/ca/cacert.pem -o /usr/lib/ssl/cert.pem

sed -ri -e 's!/var/www/html!/app/public!g' /etc/apache2/sites-available/*.conf
sed -ri -e 's!/var/www/!/app/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
echo "max_execution_time=0" > $PHP_INI_DIR/conf.d/max-execution-time.ini
echo "expose_php=off" > $PHP_INI_DIR/conf.d/expose-php.ini
#echo "default_socket_timeout=120" > $PHP_INI_DIR/conf.d/default-socket-timeout.ini

docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
docker-php-ext-configure mysqli --with-mysqli=mysqlnd
docker-php-ext-configure gd  --with-freetype --with-jpeg
docker-php-ext-install -j$(nproc) bcmath
docker-php-ext-install -j$(nproc) exif
docker-php-ext-install -j$(nproc) bz2
docker-php-ext-install -j$(nproc) curl
docker-php-ext-install -j$(nproc) fileinfo
docker-php-ext-install -j$(nproc) gd
docker-php-ext-install -j$(nproc) iconv
docker-php-ext-install -j$(nproc) intl
docker-php-ext-install -j$(nproc) mbstring
docker-php-ext-install -j$(nproc) mysqli
docker-php-ext-install -j$(nproc) opcache
#docker-php-ext-install -j$(nproc) openssl
docker-php-ext-install -j$(nproc) pcntl
docker-php-ext-install -j$(nproc) pdo
docker-php-ext-install -j$(nproc) pdo_mysql
docker-php-ext-install -j$(nproc) pdo_pgsql
docker-php-ext-install -j$(nproc) pdo_sqlite
docker-php-ext-install -j$(nproc) pgsql
docker-php-ext-install -j$(nproc) sockets
docker-php-ext-install -j$(nproc) tokenizer
docker-php-ext-install -j$(nproc) zip

# TODO: mcrypt dom gmp memcached mongodb

pecl install imagick
docker-php-ext-enable imagick

pecl install redis
docker-php-ext-enable redis

#pecl config-set php_ini "${PHP_INI_DIR}/php.ini";

#pecl install mongodb
#docker-php-ext-enable mongodb

#pecl install xdebug
#docker-php-ext-enable xdebug

#pecl install protobuf
#docker-php-ext-enable protobuf

#pecl install grpc
#docker-php-ext-enable grpc

pecl install msgpack
echo "extension=msgpack.so" > $PHP_INI_DIR/conf.d/msgpack.ini
# https://github.com/msgpack/msgpack-php
# https://github.com/rybakit/msgpack.php

#pecl clear-cache

cat <<EOF > $PHP_INI_DIR/conf.d/opcache.ini
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
EOF

a2enmod deflate
a2enmod expires
a2enmod filter
a2enmod headers
a2enmod include
a2enmod remoteip
a2enmod rewrite
a2enmod setenvif

cat <<EOF >> /etc/apache2/apache2.conf
ServerName localhost
SetEnvIf X-Forwarded-Proto "https" HTTPS=on
EOF

cat <<EOF >> /etc/apache2/conf-available/remoteip.conf
RemoteIPHeader X-Forwarded-For
RemoteIPTrustedProxy 10.0.0.0/8
RemoteIPTrustedProxy 172.16.0.0/12
RemoteIPTrustedProxy 192.168.0.0/16
RemoteIPTrustedProxy 169.254.0.0/16
RemoteIPTrustedProxy 127.0.0.0/8
EOF

a2enconf remoteip

find /etc/apache2 -type f -name '*.conf' -exec sed -ri 's/([[:space:]]*LogFormat[[:space:]]+"[^"]*)%h([^"]*")/\1%a\2/g' '{}' +

# Install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install nodejs https://github.com/nodesource/distributions
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs

# Clean
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp/* /var/tmp/*
rm /install.sh

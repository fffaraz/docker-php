#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get -yq update
apt-get -yq upgrade
apt-get -yq install \
            bash build-essential ca-certificates dnsutils git nano netbase unzip wget whois zip \
            curl libcurl4 libcurl4-openssl-dev openssl libmcrypt-dev libssl-dev \
            libfreetype6-dev libicu-dev libjpeg62-turbo-dev libonig-dev libpng-dev \
            mariadb-client libpq-dev libsqlite3-dev libbz2-dev zlib1g-dev libzip-dev

# TODO: postgresql-client default-mysql-client
# TODO: ttf-mscorefonts
# TODO: logrotate
# TODO: dropbear

#update-ca-certifcates
#wget https://curl.haxx.se/ca/cacert.pem -o /usr/lib/ssl/cert.pem

sed -ri -e 's!/var/www/html!/app/public!g' /etc/apache2/sites-available/*.conf
sed -ri -e 's!/var/www/!/app/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

echo "ServerName localhost" >> /etc/apache2/apache2.conf
echo "RemoteIPHeader X-Forwarded-For" >> /etc/apache2/apache2.conf
echo 'SetEnvIf X-Forwarded-Proto "https" HTTPS=on' >> /etc/apache2/apache2.conf

cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
echo "max_execution_time=0" > $PHP_INI_DIR/conf.d/max-execution-time.ini
echo "expose_php=off" > $PHP_INI_DIR/conf.d/expose-php.ini
#echo "default_socket_timeout=60" > $PHP_INI_DIR/conf.d/default-socket-timeout.ini

docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
docker-php-ext-configure mysqli --with-mysqli=mysqlnd
docker-php-ext-configure gd  --with-freetype --with-jpeg
docker-php-ext-install -j$(nproc) bcmath
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
# TODO: mcrypt dom gmp imagick memcached mongodb exif

#pecl config-set php_ini "${PHP_INI_DIR}/php.ini";

#pecl install mongodb
#docker-php-ext-enable mongodb

#pecl install redis-5.1.1
#docker-php-ext-enable redis

#pecl install xdebug-2.8.1
#docker-php-ext-enable xdebug

#pecl install grpc
#pecl install protobuf
#docker-php-ext-enable grpc
#docker-php-ext-enable protobuf

pecl install msgpack
echo "extension=msgpack.so" > $PHP_INI_DIR/conf.d/msgpack.ini
# https://github.com/msgpack/msgpack-php
# https://github.com/rybakit/msgpack.php

#pecl clear-cache

a2enmod deflate
a2enmod expires
a2enmod filter
a2enmod headers
a2enmod include
a2enmod remoteip
a2enmod rewrite
a2enmod setenvif

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

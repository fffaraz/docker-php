FROM php:7-fpm

RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -yq update && \
	apt-get -yq upgrade && \
	apt-get -yq --no-install-recommends install \
	curl git nano ca-certificates dnsutils netbase unzip wget whois zip sendmail procps \
	libfreetype6-dev libicu-dev libjpeg-dev libjpeg62-turbo-dev libmagickwand-dev libpng-dev libwebp-dev libzip-dev zlib1g-dev \
	iputils-ping libcurl4 libcurl4-openssl-dev openssl libmcrypt-dev libssl-dev libxml2-dev libldap2-dev \
	libpq-dev libsqlite3-dev libbz2-dev libonig-dev dropbear && \
	curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
	apt-get -y install nodejs && \
	rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp/* /var/tmp/* && \
	exit 0

RUN \
	docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
	docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
	docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
	docker-php-ext-install -j "$(nproc)" bcmath exif bz2 curl fileinfo iconv gd intl mysqli opcache zip mbstring pdo pdo_pgsql pdo_mysql pdo_sqlite pgsql pcntl sockets soap zip ldap && \
	docker-php-ext-enable zip ldap && \
	pecl install imagick && docker-php-ext-enable imagick && \
	pecl install redis && docker-php-ext-enable redis && \
	pecl install msgpack && echo "extension=msgpack.so" > $PHP_INI_DIR/conf.d/msgpack.ini && \
	exit 0

# curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
	exit 0

COPY docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY myphp.ini /usr/local/etc/php/conf.d/myphp.ini

WORKDIR /app

FROM php:fpm

RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -yq update && \
	apt-get -yq upgrade && \
	apt-get -yq --no-install-recommends install \
	curl git nano ca-certificates dnsutils netbase unzip wget whois zip \
	libfreetype6-dev libicu-dev libjpeg-dev libmagickwand-dev libpng-dev libwebp-dev libzip-dev libonig-dev && \
	rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp/* /var/tmp/* && \
	exit 0

RUN \
	docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
	docker-php-ext-install -j "$(nproc)" bcmath exif gd intl mysqli zip mbstring pdo pdo_mysql && \
	exit 0

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
	exit 0

COPY docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY myphp.ini /usr/local/etc/php/conf.d/myphp.ini

WORKDIR /app

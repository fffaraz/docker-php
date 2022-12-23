FROM php:fpm

RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -yq update && \
	apt-get -yq upgrade && \
	apt-get -yq --no-install-recommends install \
	curl git nano ca-certificates dnsutils netbase unzip wget whois zip \
	libfreetype6-dev libicu-dev libjpeg-dev libmagickwand-dev libpng-dev libwebp-dev libzip-dev && \
	rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp/* /var/tmp/* && \
	exit 0

RUN \
	docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
	docker-php-ext-install -j "$(nproc)" bcmath exif gd intl mysqli zip && \
	exiit 0

COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY myphp.ini /usr/local/etc/php/conf.d/myphp.ini

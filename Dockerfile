FROM php:fpm

RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -yq update && \
	apt-get -yq upgrade && \
	apt-get -yq install curl git nano ca-certificates dnsutils netbase unzip wget whois zip && \
	rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp/* /var/tmp/* && \
	exit 0

COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY myphp.ini /usr/local/etc/php/conf.d/myphp.ini

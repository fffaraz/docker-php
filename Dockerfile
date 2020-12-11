FROM php:7-apache

ENTRYPOINT ["/docker-entrypoint.sh"]
#EXPOSE 80 22
#VOLUME /app
WORKDIR /app

COPY docker-install.sh /
RUN chown root:root /docker-install.sh && chmod 544 /docker-install.sh && sync && /docker-install.sh

COPY docker-entrypoint.sh /
RUN chown root:root /docker-entrypoint.sh && chmod 544 /docker-entrypoint.sh

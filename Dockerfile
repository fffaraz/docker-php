FROM php:apache

ENTRYPOINT ["/entrypoint.sh"]
ENV TERM xterm
EXPOSE 80
VOLUME /app
WORKDIR /app

COPY install.sh /
RUN chown root:root /install.sh && chmod 544 /install.sh && sync && /install.sh

COPY entrypoint.sh /
RUN chown root:root /entrypoint.sh && chmod 544 /entrypoint.sh

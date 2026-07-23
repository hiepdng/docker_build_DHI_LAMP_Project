### 1. Build Stage: Use the DHI Debian dev image to install tools
FROM dhi.io/php:8.5.8-debian13-dev AS builder

## Install redis
RUN git clone https://github.com/phpredis/phpredis.git \
    && cd phpredis \
    && phpize \
    && ./configure \
    && make \
    && make install
RUN echo "extension=redis.so" > /opt/php/etc/php/conf.d/redis.ini

RUN mkdir -p /opt/php/mysql_certs



### 2. Final Stage: Copy the compiled site into a minimal production image
FROM dhi.io/php:8.5.8-debian13-fpm

## Config redis
COPY --from=builder /opt/php/lib/php/extensions /opt/php/lib/php/extensions/
COPY --from=builder /opt/php/etc/php/conf.d/redis.ini /opt/php/etc/php/conf.d/redis.ini

COPY --from=builder /opt/php/mysql_certs /opt/php/mysql_certs

EXPOSE 9000

ENTRYPOINT ["/opt/php-8.5/sbin/php-fpm"]

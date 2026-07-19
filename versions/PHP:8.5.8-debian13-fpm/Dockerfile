### To build docker php image:
# $ docker build -t dhi.io/php:8.5.8-debian13-fpm .
#----------------------------------------------------------------

### 1. Build Stage: Use the DHI Debian dev image to install tools
FROM dhi.io/php:8.5.8-debian13-dev AS builder

# Example: Install build tools and compile/prepare your web content
WORKDIR /app
COPY php.ini .

# Install redis
RUN git clone https://github.com/phpredis/phpredis.git \
    && cd phpredis \
    && phpize \
    && ./configure \
    && make \
    && make install
RUN echo "extension=redis.so" > /opt/php-8.5/etc/php/conf.d/redis.ini


### 2. Final Stage: Copy the compiled site into a minimal production image
FROM dhi.io/php:8.5.8-debian13-fpm

# Copy config files from the builder stage into production system
COPY --chown=65532:65532 --from=builder /app/php.ini /opt/php-8.5/etc/php/

COPY --from=builder /opt/php-8.5/lib/php/extensions /opt/php-8.5/lib/php/extensions/
COPY --from=builder /opt/php-8.5/etc/php/conf.d/redis.ini /opt/php-8.5/etc/php/conf.d/redis.ini

EXPOSE 9000

ENTRYPOINT ["/opt/php-8.5/sbin/php-fpm"]

### 1. Build Stage: Use the DHI Debian dev image to install tools
FROM dhi.io/php:8.5.8-debian13-dev AS builder

## You could either copy your php.ini or modify it directly
#WORKDIR /app
#COPY php.ini .

## Modify the php.ini directly
RUN sed -i \
        -e "s/^\(max_execution_time.*\)/;\1\nmax_execution_time = 60/" \
        -e "s/^\(max_input_time.*\)/;\1\nmax_input_time = 60/" \
        -e "s/^\(;max_input_vars.*\)/;\1\nmax_input_vars = 3000/" \
        -e "s/^\(memory_limit.*\)/;\1\nmemory_limit = 256M/" \
        -e "s/^\(post_max_size.*\)/;\1\npost_max_size = 64M/" \
        -e "s/^\(upload_max_filesize.*\)/;\1\nupload_max_filesize = 64M/" \
        -e "s/^\(display_errors.*\)/;\1\ndisplay_errors = Off/" \
        -e "s/^\(display_startup_errors.*\)/;\1\ndisplay_startup_errors = Off/" \
        -e "s/^\(log_errors.*\)/;\1\nlog_error = On/" \
        -e "s/^\(error_reporting.*\)/;\1\nerror_reporting = E_ALL \\& ~E_DEPRECATED \\& ~E_STRICT/" \
        -e "s/^\(expose_php.*\)/;\1\nexpose_php = Off/" \
        -e "s/^\(session.use_only_cookies.*\)/;\1\nsession.use_only_cookies = 1/" \
        -e "s/^\(session.cookie_httponly.*\)/;\1\nsession.cookie_httponly = 1/" \
        -e "s/^;\(session.cookie_secure.*\)/;\1\nsession.cookie_secure = 1/" \
        -e "s/^\(session.use_strict_mode.*\)/;\1\nsession.use_strict_mode = 1/" \
        -e "s/^\(session.cookie_samesite.*\)/;\1\nsession.cookie_samesite = "Lax"/" \
        -e "s/^\(allow_url_fopen.*\)/;\1\nallow_url_fopen = Off/" \
        -e "s/^\(allow_url_include.*\)/;\1\nallow_url_include = Off/" \
        -e "s/^\(disable_functions.*\)/;\1\ndisable_functions = exec,shell_exec,passthru,system,popen,proc_open/" \
        -e "s/^;\(opcache.enable=.*\)/;\1\nopcache.enable = 1/" \
        -e "s/^;\(opcache.enable_cli.*\)/;\1\nopcache.enable_cli = 1/" \
        -e "s/^;\(opcache.memory_consumption.*\)/;\1\nopcache.memory_consumption = 128/" \
        -e "s/^;\(opcache.interned_strings_buffer.*\)/;\1\nopcache.interned_strings_buffer = 8/" \
        -e "s/^;\(opcache.max_accelerated_files.*\)/;\1\nopcache.max_accelerated_files = 10000/" \
        -e "s/^;\(opcache.validate_timestamps.*\)/;\1\nopcache.validate_timestamps = 0/" \
    /opt/php-8.5/etc/php/php.ini

## Install redis
RUN git clone https://github.com/phpredis/phpredis.git \
    && cd phpredis \
    && phpize \
    && ./configure \
    && make \
    && make install
RUN echo "extension=redis.so" > /opt/php-8.5/etc/php/conf.d/redis.ini


### 2. Final Stage: Copy the compiled site into a minimal production image
FROM dhi.io/php:8.5.8-debian13-fpm

## Copy config files from the builder stage into production system
#COPY --chown=65532:65532 --from=builder /app/php.ini /opt/php-8.5/etc/php/
COPY --chown=65532:65532 --from=builder /opt/php-8.5/etc/php/php.ini /opt/php-8.5/etc/php/

## Config redis
COPY --from=builder /opt/php-8.5/lib/php/extensions /opt/php-8.5/lib/php/extensions/
COPY --from=builder /opt/php-8.5/etc/php/conf.d/redis.ini /opt/php-8.5/etc/php/conf.d/redis.ini

EXPOSE 9000

ENTRYPOINT ["/opt/php-8.5/sbin/php-fpm"]

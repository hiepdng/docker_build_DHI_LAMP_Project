# 1. Build Stage: Use the DHI Debian dev image to install tools and build your web assets
FROM dhi.io/httpd:2.4.68-debian13-dev AS builder

# Example: Install build tools and compile/prepare your web content
WORKDIR /app
COPY httpd.conf .
COPY server.crt .
COPY server.key .
COPY httpd-ssl.conf .


# 2. Final Stage: Copy the compiled site into a minimal production image
FROM dhi.io/httpd:2.4.68-debian13

# Copy config files from the builder stage into production system
COPY --chown=65532:65532 --from=builder /app/httpd.conf /usr/local/apache2/conf/
COPY --chown=65532:65532 --from=builder /app/server.crt /usr/local/apache2/conf/
COPY --chown=65532:65532 --from=builder /app/server.key /usr/local/apache2/conf/
COPY --chown=65532:65532 --from=builder /app/httpd-ssl.conf /usr/local/apache2/conf/extra/

EXPOSE 8080 443

ENTRYPOINT ["httpd-foreground"]

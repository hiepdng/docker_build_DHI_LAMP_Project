# 1. Build Stage: Use the DHI Debian dev image to install tools and build your web assets
FROM dhi.io/httpd:2.4.68-debian13-dev AS builder

WORKDIR /app

# Create CA Certificates
RUN openssl genrsa -out my-internal-ca.key 2048
RUN openssl req -x509 -new -nodes -key my-internal-ca.key -sha256 -days 1826 -out my-internal-ca.crt  -subj ${CERT_SUBJ}
COPY my-internal-ca.crt /usr/local/share/ca-certificates/my-internal-ca.crt
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    update-ca-certificates
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Create a self-signed SSL Certificate for testing purposes:
RUN openssl genrsa -des3 -passout pass:YourPasswordHere -out server.key.secure 
RUN openssl rsa -in server.key.secure -passin pass:YourPasswordHere -out server.key # decrypted server.key, used for auto start web withour password
RUN openssl req -new -x509 -nodes -sha1 -days 365 -key server.key -out server.crt -extensions usr_cert  -subj ${CERT_SUBJ}

COPY httpd.conf .
COPY httpd-ssl.conf .

RUN sed -i \
        -e "s/^#\(Include .*httpd-ssl.conf\)/\1/" \
        -e "s/^#\(LoadModule .*mod_ssl.so\)/\1/" \
        -e "s/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/" \
        -e "s/^#ServerName www.example.com:80/ServerName ${SERVER_NAME}/" \
    /usr/local/apache2/conf/httpd.conf

RUN sed -i \
        -e "s/^ServerName www.example.com:443/ServerName ${SERVER_NAME}:443/" \
        -e "s/^ServerAdmin you@example.com/ServerAdmin ${SERVER_ADMIN}/" \
    /usr/local/apache2/conf/extra/httpd-ssl.conf

    

# 2. Final Stage: Copy the compiled site into a minimal production image
FROM dhi.io/httpd:2.4.68-debian13

# Copy config files from the builder stage into production system
USER 0
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

USER 65532
COPY --chown=65532:65532 --from=builder /app/httpd.conf /usr/local/apache2/conf/
COPY --chown=65532:65532 --from=builder /app/server.crt /usr/local/apache2/conf/
COPY --chown=65532:65532 --from=builder /app/server.key /usr/local/apache2/conf/
COPY --chown=65532:65532 --from=builder /app/httpd-ssl.conf /usr/local/apache2/conf/extra/

EXPOSE 8080 443

ENTRYPOINT ["httpd-foreground"]

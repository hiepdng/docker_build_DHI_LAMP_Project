# 1. Build Stage: Use the DHI Debian dev image to install tools and build your web assets
FROM dhi.io/httpd:2.4.68-debian13-dev AS builder

WORKDIR /app

ARG CERT_SUBJ
ARG SERVER_NAME
ARG SERVER_ADMIN

# Create CA Certificates
RUN mkdir -p /usr/local/share/ca-certificates/
RUN openssl genrsa -out /app/my-internal-ca.key 2048
RUN openssl req -x509 -new -nodes -key /app/my-internal-ca.key -sha256 -days 1826 -out /usr/local/share/ca-certificates/my-internal-ca.crt  -subj ${CERT_SUBJ}

# Modify httpd.conf file
RUN sed -i \
        -e "s/^#\(Include .*httpd-ssl.conf\)/\1/" \
        -e "s/^#\(LoadModule .*mod_ssl.so\)/\1/" \
        -e "s/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/" \
        -e "s/^#ServerName www.example.com:80/ServerName ${SERVER_NAME}/" \
    /usr/local/apache2/conf/httpd.conf

# Modify httpd-ssl.conf file
RUN sed -i \
        -e "s/^ServerName www.example.com:443/ServerName ${SERVER_NAME}:443/" \
        -e "s/^ServerAdmin you@example.com/ServerAdmin ${SERVER_ADMIN}/" \
        -e "s/^SSLCertificateFile.*/SSLCertificateFile \/usr\/local\/apache2\/conf\/certs\/server.crt/" \
        -e "s/^SSLCertificateKeyFile.*/SSLCertificateKeyFile \/usr\/local\/apache2\/conf/certs\/server.key/" \
    /usr/local/apache2/conf/extra/httpd-ssl.conf



# 2. Final Stage: Copy the compiled site into a minimal production image
FROM dhi.io/httpd:2.4.68-debian13-dev

# Copy config files from the builder stage into production system
USER root
RUN mkdir -p /usr/local/share/ca-certificates/
COPY --from=builder /usr/local/share/ca-certificates/my-internal-ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

USER 65532
RUN mkdir -p /usr/local/apache2/conf/certs
COPY --from=builder /usr/local/apache2/conf/extra/httpd-ssl.conf /usr/local/apache2/conf/extra/

EXPOSE 8080 443

ENTRYPOINT ["httpd-foreground"]

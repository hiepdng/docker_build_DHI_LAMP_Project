FROM dhi.io/mysql:lts-debian13

# Copy Certificate
COPY --chown=65532:65532 ca.pem /etc/
COPY --chown=65532:65532 server-cert.pem /etc/
COPY --chown=65532:65532 --chmod=600 server-key.pem /etc/

# Copy my.cnf
COPY --chown=65532:65532 my.cnf /etc/my.cnf

EXPOSE 3306 33060

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

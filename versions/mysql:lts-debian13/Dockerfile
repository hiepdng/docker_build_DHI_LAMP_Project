FROM dhi.io/mysql:lts-debian13

# Create certs directory
USER 0
RUN mkdir -p /opt/mysql/certs

USER 65532
EXPOSE 3306 33060 

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

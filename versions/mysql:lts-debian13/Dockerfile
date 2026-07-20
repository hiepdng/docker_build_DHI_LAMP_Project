# 1. Build Stage: Use the DHI Debian dev image to install tools and build your web assets
FROM dhi.io/mysql:lts-debian13-dev AS builder

WORKDIR /app
ARG MYCNF
RUN echo ${MYCNF} > /app/my.cnf



# 2. Final Stage: Copy the compiled site into a minimal production image
FROM dhi.io/mysql:lts-debian13

# Copy Certificate
COPY --chown=65532:65532 ca.pem /etc/
COPY --chown=65532:65532 server-cert.pem /etc/
COPY --chown=65532:65532 --chmod=600 server-key.pem /etc/

# Copy my.cnf
COPY  --from=builder --chown=65532:65532 /app/my.cnf /etc/my.cnf

EXPOSE 3306 33060 

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

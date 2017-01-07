FROM debian
RUN apt-get update && \
    apt-get install -y --no-install-recommends opendkim opendkim-tools openssl && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean

EXPOSE 5500
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY tools/init-db.sh /usr/local/bin/init-db.sh
COPY tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/init-db.sh

EXPOSE 3306
CMD ["/usr/local/bin/start.sh"]
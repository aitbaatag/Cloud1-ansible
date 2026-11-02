#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld
SOCK=/run/mysqld/mysqld.sock
MARKER=/var/lib/mysql/.cloud1_initialized

if [ ! -f "$MARKER" ]; then
  if [ ! -d /var/lib/mysql/mysql ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null
  fi

  mysqld --user=mysql --skip-networking --socket=$SOCK &
  pid=$!
  until mysqladmin --socket=$SOCK ping --silent; do sleep 1; done

  mysql --socket=$SOCK <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  mysqladmin --socket=$SOCK -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait $pid
  touch "$MARKER"
fi

exec mysqld --user=mysql --bind-address=0.0.0.0
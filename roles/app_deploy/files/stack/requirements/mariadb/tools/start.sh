#!/bin/bash
set -e

# Start MariaDB in background
mysqld_safe &
MARIADB_PID=$!

# Wait until the server answers 
until mysqladmin ping --silent 2>/dev/null; do
  sleep 1
done

# Run init script
/usr/local/bin/init-db.sh

# Keep the container alive
wait $MARIADB_PID
#!/usr/bin/env bash
set -e

DB_DIR="/tmp/mysql_fieldnotes"
SOCKET="/tmp/fieldnotes_mysql.sock"
PORT=3307

echo "==> Checking MySQL instance on port $PORT..."
if ! nc -z 127.0.0.1 $PORT 2>/dev/null; then
    echo "==> Initializing datadir at $DB_DIR if needed..."
    mkdir -p "$DB_DIR"
    if [ ! -d "$DB_DIR/mysql" ]; then
        /usr/sbin/mysqld --no-defaults --initialize-insecure --datadir="$DB_DIR"
    fi

    echo "==> Starting local mysqld on port $PORT..."
    /usr/sbin/mysqld --no-defaults --datadir="$DB_DIR" --port=$PORT --socket="$SOCKET" --bind-address=127.0.0.1 &
    sleep 2
    mysql -u root -h 127.0.0.1 -P $PORT -e "CREATE DATABASE IF NOT EXISTS field_notes;"
    echo "==> Database 'field_notes' is ready on 127.0.0.1:$PORT"
else
    echo "==> MySQL is already running on port $PORT"
fi

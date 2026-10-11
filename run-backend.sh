#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure DB is running
"$SCRIPT_DIR/start-db.sh"

export JAVA_HOME="/home/saiful-islam/tools/jdk-21"
export PATH="$JAVA_HOME/bin:/home/saiful-islam/tools/maven/bin:$PATH"

echo "==> Starting Spring Boot backend on port 8080..."
cd "$SCRIPT_DIR/backend"
mvn spring-boot:run

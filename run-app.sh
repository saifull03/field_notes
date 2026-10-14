#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/home/saiful-islam/tools/flutter/bin:$PATH"

# In Ubuntu 24.10/25.10, google-chrome has a known GTK/GIO antialiasing crash.
# If Brave is available and CHROME_EXECUTABLE is not set, default to Brave.
if [ -z "$CHROME_EXECUTABLE" ] && [ -x "/snap/bin/brave" ]; then
    export CHROME_EXECUTABLE="/snap/bin/brave"
fi

cd "$SCRIPT_DIR/mobile"

if [ $# -eq 0 ]; then
    echo "==> Starting Flutter Web Server on http://localhost:3000..."
    echo "==> Open http://localhost:3000 in your browser (Chrome, Brave, Firefox)."
    echo "==> Alternatively, you can run:"
    echo "       ./run-app.sh -d linux        # Native Linux Desktop App"
    echo "       ./run-app.sh -d web-server   # Custom Web Server"
    flutter run -d web-server --web-port=3000 --web-hostname=localhost
else
    echo "==> Running Flutter App with arguments: $*"
    flutter run "$@"
fi

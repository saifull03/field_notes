#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/home/saiful-islam/tools/flutter/bin:$PATH"

echo "==> Running Flutter Mobile App..."
cd "$SCRIPT_DIR/mobile"
flutter run "$@"


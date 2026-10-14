#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="/home/saiful-islam/tools/flutter/bin:/home/saiful-islam/tools/jdk-21/bin:$PATH"
export JAVA_HOME="/home/saiful-islam/tools/jdk-21"
export ANDROID_HOME="/home/saiful-islam/Android/Sdk"

BUILD_TYPE="release"
if [ "$1" == "--debug" ]; then
    BUILD_TYPE="debug"
fi

echo "==> Building Android APK ($BUILD_TYPE)..."
cd "$SCRIPT_DIR/mobile"

if [ "$BUILD_TYPE" == "debug" ]; then
    flutter build apk --debug
    OUTPUT_APK="$SCRIPT_DIR/mobile/build/app/outputs/flutter-apk/app-debug.apk"
else
    flutter build apk --release
    OUTPUT_APK="$SCRIPT_DIR/mobile/build/app/outputs/flutter-apk/app-release.apk"
fi

echo ""
echo "=========================================================="
echo "✓ APK built successfully!"
echo "Location: $OUTPUT_APK"
echo "Size: $(ls -lh "$OUTPUT_APK" | awk '{print $5}')"
echo "=========================================================="
echo ""
echo "To install on a connected Android phone or emulator via ADB:"
echo "  /home/saiful-islam/Android/Sdk/platform-tools/adb install -r $OUTPUT_APK"
echo ""
echo "Or transfer '$OUTPUT_APK' to your mobile device directly."


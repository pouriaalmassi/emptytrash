#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/Empty Trash.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
xcrun swiftc -O -swift-version 5 -target arm64-apple-macosx12.0 \
    "$ROOT/Sources/TrashCleaner.swift" "$ROOT/Sources/main.swift" \
    -o "$APP/Contents/MacOS/EmptyTrash"
ICONSET="$(mktemp -d)/AppIcon.iconset"
trap 'rm -rf "$(dirname "$ICONSET")"' EXIT
mkdir -p "$ICONSET"
xcrun swift "$ROOT/scripts/make-icon.swift" "$ICONSET"
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
codesign --force --options runtime --sign "${SIGNING_IDENTITY:--}" "$APP"
codesign --verify --strict "$APP"
printf 'Built %s\n' "$APP"

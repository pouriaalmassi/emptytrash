#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/build.sh"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
ditto "$ROOT/build/Empty Trash.app" "$STAGING/Empty Trash.app"
ln -s /Applications "$STAGING/Applications"
cp "$ROOT/INSTALL.txt" "$STAGING/INSTALL.txt"
mkdir -p "$ROOT/dist"
DMG="$ROOT/dist/EmptyTrash-arm64.dmg"
hdiutil create -ov -volname "Empty Trash" -srcfolder "$STAGING" -format UDZO "$DMG"
if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
    codesign --force --sign "$SIGNING_IDENTITY" "$DMG"
fi
if [[ -n "${NOTARY_PROFILE:-}" ]]; then
    xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG"
fi
printf 'Created %s\n' "$DMG"

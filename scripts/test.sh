#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT
xcrun swiftc "$ROOT/Sources/TrashCleaner.swift" "$ROOT/Tests/main.swift" -o "$TEMP/test"
"$TEMP/test"

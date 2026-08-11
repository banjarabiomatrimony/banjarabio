#!/bin/bash
# Fix: "Plugin directory does not exist: .../app_links-X.X.X/android"
# Caused by corrupted/incomplete package in pub cache. Re-download fixes it.
set -e
echo "Removing app_links from pub cache..."
CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
rm -rf "$CACHE/hosted/pub.dev/app_links-"* 2>/dev/null || true
echo "Running flutter clean..."
flutter clean
echo "Re-fetching dependencies..."
flutter pub get
echo "Done. Try: flutter build apk --debug"
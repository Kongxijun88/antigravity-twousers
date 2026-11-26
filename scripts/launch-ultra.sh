#!/usr/bin/env bash
#
# Standalone CLI runner for Antigravity Ultra (Instance 3)
# Useful for debugging or launching directly from terminal.
#
set -euo pipefail

ULTRA_HOME="$HOME/.antigravity-ultra-home"
KEYCHAIN_PATH="$ULTRA_HOME/Library/Keychains/login.keychain-db"
KEY_FILE="$ULTRA_HOME/.keychain_secret"
APP_EXEC="/Applications/Antigravity.app/Contents/MacOS/Antigravity"

if [[ ! -f "$KEYCHAIN_PATH" ]] || [[ ! -f "$KEY_FILE" ]]; then
    echo "❌ Dedicated environment not initialized at $ULTRA_HOME"
    echo "Please run ./install-ultra.sh first."
    exit 1
fi

KEYCHAIN_PASS=$(cat "$KEY_FILE")

echo "==> Unlocking secondary isolated keychain for Antigravity Ultra..."
security unlock-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN_PATH" 2>/dev/null || true
security set-keychain-settings "$KEYCHAIN_PATH" 2>/dev/null || true

echo "==> Launching Antigravity Ultra..."
export HOME="$ULTRA_HOME"
exec "$APP_EXEC" --user-data-dir="$ULTRA_HOME/Library/Application Support/Antigravity" "$@"

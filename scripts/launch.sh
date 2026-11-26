#!/usr/bin/env bash
#
# Standalone CLI runner for Antigravity Instance 2
# Useful for debugging or launching directly from terminal.
#
set -euo pipefail

PRO2_HOME="$HOME/.antigravity-pro2-home"
KEYCHAIN_PATH="$PRO2_HOME/Library/Keychains/login.keychain-db"
KEY_FILE="$PRO2_HOME/.keychain_secret"
APP_EXEC="/Applications/Antigravity.app/Contents/MacOS/Antigravity"

if [[ ! -f "$KEYCHAIN_PATH" ]] || [[ ! -f "$KEY_FILE" ]]; then
    echo "❌ Dedicated environment not initialized at $PRO2_HOME"
    echo "Please run ./install.sh first."
    exit 1
fi

KEYCHAIN_PASS=$(cat "$KEY_FILE")

echo "==> Unlocking secondary isolated keychain..."
security unlock-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN_PATH" 2>/dev/null || true
security set-keychain-settings "$KEYCHAIN_PATH" 2>/dev/null || true

echo "==> Launching Antigravity Instance 2..."
export HOME="$PRO2_HOME"
exec "$APP_EXEC" --user-data-dir="$PRO2_HOME/Library/Application Support/Antigravity" "$@"

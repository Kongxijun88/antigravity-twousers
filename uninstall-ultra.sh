#!/usr/bin/env bash
#
# Antigravity Ultra (Instance 3) Uninstaller for macOS
# Cleanly removes the third Antigravity Ultra instance.
#
set -euo pipefail

echo "============================================================"
echo "   Antigravity Ultra (Instance 3) Uninstaller for macOS"
echo "============================================================"

APP_TARGET="/Applications/Antigravity Ultra.app"
ULTRA_HOME="$HOME/.antigravity-ultra-home"
KEYCHAIN_PATH="$ULTRA_HOME/Library/Keychains/login.keychain-db"

echo "==> Step 1: Stopping running processes of Antigravity Ultra..."
pkill -f "antigravity-ultra-home" 2>/dev/null || true

echo "==> Step 2: Removing /Applications/Antigravity Ultra.app..."
if [[ -d "$APP_TARGET" ]]; then
    rm -rf "$APP_TARGET"
    echo "  ✓ Removed $APP_TARGET"
else
    echo "  ✓ $APP_TARGET not found."
fi

echo "==> Step 3: Removing Antigravity Ultra from Dock..."
python3 -c "
import subprocess, plistlib

try:
    res = subprocess.run(['defaults', 'export', 'com.apple.dock', '-'], stdout=subprocess.PIPE, check=True)
    dock = plistlib.loads(res.stdout)
    apps = dock.get('persistent-apps', [])

    new_apps = [
        a for a in apps
        if 'antigravity ultra' not in a.get('tile-data', {}).get('file-label', '').lower()
        and 'Antigravity%20Ultra.app' not in a.get('tile-data', {}).get('file-data', {}).get('_CFURLString', '')
    ]

    if len(new_apps) != len(apps):
        dock['persistent-apps'] = new_apps
        subprocess.run(['defaults', 'import', 'com.apple.dock', '-'], input=plistlib.dumps(dock), check=True)
        subprocess.run(['killall', 'Dock'], check=True)
        print('  ✓ Removed from Dock.')
    else:
        print('  ✓ Not found in Dock.')
except Exception as e:
    print(f'  ⚠️ Notice: Could not update Dock ({e}).')
"

echo "==> Step 4: Ultra User Data Profile"
echo "Data directory: $ULTRA_HOME"
read -p "Do you want to permanently delete the Ultra profile and isolated keychain ($ULTRA_HOME)? (y/N): " -r choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    if [[ -f "$KEYCHAIN_PATH" ]]; then
        security delete-keychain "$KEYCHAIN_PATH" 2>/dev/null || true
    fi
    rm -rf "$ULTRA_HOME"
    echo "  ✓ Completely deleted $ULTRA_HOME and its isolated keychain."
else
    if [[ -f "$KEYCHAIN_PATH" ]]; then
        security lock-keychain "$KEYCHAIN_PATH" 2>/dev/null || true
    fi
    echo "  ✓ Kept $ULTRA_HOME (isolated keychain has been locked)."
fi

echo "============================================================"
echo "🎉 Uninstallation complete! Original Antigravity & Pro 2 were untouched."
echo "============================================================"

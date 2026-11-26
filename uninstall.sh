#!/usr/bin/env bash
#
# Antigravity Dual Instance Uninstaller for macOS
# Cleanly removes the secondary Antigravity Pro 2 instance.
#
set -euo pipefail

echo "============================================================"
echo "   Antigravity Dual Instance Uninstaller for macOS"
echo "============================================================"

APP_TARGET="/Applications/Antigravity Pro 2.app"
PRO2_HOME="$HOME/.antigravity-pro2-home"
KEYCHAIN_PATH="$PRO2_HOME/Library/Keychains/login.keychain-db"

echo "==> Step 1: Stopping running processes of Antigravity Pro 2..."
pkill -f "antigravity-pro2-home" 2>/dev/null || true

echo "==> Step 2: Removing /Applications/Antigravity Pro 2.app..."
if [[ -d "$APP_TARGET" ]]; then
    rm -rf "$APP_TARGET"
    echo "  ✓ Removed $APP_TARGET"
else
    echo "  ✓ $APP_TARGET not found."
fi

echo "==> Step 3: Removing Antigravity Pro 2 from Dock..."
python3 -c "
import subprocess, plistlib

try:
    res = subprocess.run(['defaults', 'export', 'com.apple.dock', '-'], stdout=subprocess.PIPE, check=True)
    dock = plistlib.loads(res.stdout)
    apps = dock.get('persistent-apps', [])

    new_apps = [
        a for a in apps
        if 'antigravity pro 2' not in a.get('tile-data', {}).get('file-label', '').lower()
        and 'Antigravity%20Pro%202.app' not in a.get('tile-data', {}).get('file-data', {}).get('_CFURLString', '')
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

echo "==> Step 4: Secondary User Data Profile"
echo "Data directory: $PRO2_HOME"
read -p "Do you want to permanently delete the secondary profile and isolated keychain ($PRO2_HOME)? (y/N): " -r choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    if [[ -f "$KEYCHAIN_PATH" ]]; then
        security delete-keychain "$KEYCHAIN_PATH" 2>/dev/null || true
    fi
    rm -rf "$PRO2_HOME"
    echo "  ✓ Completely deleted $PRO2_HOME and its isolated keychain."
else
    if [[ -f "$KEYCHAIN_PATH" ]]; then
        security lock-keychain "$KEYCHAIN_PATH" 2>/dev/null || true
    fi
    echo "  ✓ Kept $PRO2_HOME (isolated keychain has been locked)."
fi

echo "============================================================"
echo "🎉 Uninstallation complete! Original Antigravity was untouched."
echo "============================================================"

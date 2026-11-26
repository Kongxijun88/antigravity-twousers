#!/usr/bin/env bash
#
# Antigravity Dual Instance Installer for macOS
# Creates a completely sandboxed, isolated second instance of Google Antigravity.
#
set -euo pipefail

echo "============================================================"
echo "   Antigravity Dual Instance Installer for macOS"
echo "============================================================"

# 1. Environment Checks
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ Error: This script is only supported on macOS."
    exit 1
fi

APP_SOURCE="/Applications/Antigravity.app"
APP_TARGET="/Applications/Antigravity Pro 2.app"
PRO2_HOME="$HOME/.antigravity-pro2-home"
KEYCHAIN_PATH="$PRO2_HOME/Library/Keychains/login.keychain-db"
KEY_FILE="$PRO2_HOME/.keychain_secret"

if [[ ! -d "$APP_SOURCE" ]]; then
    echo "❌ Error: Antigravity is not installed at $APP_SOURCE"
    echo "Please download and install Antigravity first from https://antigravity.google"
    exit 1
fi

echo "==> Step 1: Setting up isolated home directory..."
mkdir -p "$PRO2_HOME"
mkdir -p "$PRO2_HOME/Library/Keychains"
mkdir -p "$PRO2_HOME/Library/Application Support/Antigravity"

# Bridge common user directories via symlinks so user files are accessible
ln -sf "$HOME/Desktop" "$PRO2_HOME/Desktop"
ln -sf "$HOME/Documents" "$PRO2_HOME/Documents"
ln -sf "$HOME/Downloads" "$PRO2_HOME/Downloads"
echo "  ✓ Directory sandbox created at: $PRO2_HOME"

echo "==> Step 2: Configuring dedicated Keychain with secure random secret..."
# Generate a cryptographically secure 256-bit random password if not present
if [[ ! -f "$KEY_FILE" ]]; then
    KEYCHAIN_PASS=$(openssl rand -hex 32)
    echo -n "$KEYCHAIN_PASS" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    echo "  ✓ Generated unique random 256-bit secret stored in $KEY_FILE (chmod 600)"
else
    KEYCHAIN_PASS=$(cat "$KEY_FILE")
    chmod 600 "$KEY_FILE"
fi

# Create dedicated keychain if not present
if [[ ! -f "$KEYCHAIN_PATH" ]]; then
    security create-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN_PATH"
    chmod 600 "$KEYCHAIN_PATH"
fi

# Unlock and set settings: disable timeout and sleep locking for smooth background token refresh
security unlock-keychain -p "$KEYCHAIN_PASS" "$KEYCHAIN_PATH" 2>/dev/null || true
security set-keychain-settings "$KEYCHAIN_PATH" 2>/dev/null || true
echo "  ✓ Dedicated Keychain secured and configured (no hardcoded password, strictly isolated)"

echo "==> Step 3: Compiling Antigravity Pro 2 launcher..."
# Compile AppleScript launcher applet that securely reads the dynamic secret at launch
APPLET_SCRIPT="do shell script \"PRO2_HOME=\\\"$PRO2_HOME\\\"; KEY_FILE=\\\"\$PRO2_HOME/.keychain_secret\\\"; KEYCHAIN_PATH=\\\"\$PRO2_HOME/Library/Keychains/login.keychain-db\\\"; if [ -f \\\"\$KEY_FILE\\\" ]; then KEYCHAIN_PASS=\$(cat \\\"\$KEY_FILE\\\"); security unlock-keychain -p \\\"\$KEYCHAIN_PASS\\\" \\\"\$KEYCHAIN_PATH\\\" 2>/dev/null; security set-keychain-settings \\\"\$KEYCHAIN_PATH\\\" 2>/dev/null; fi; export HOME=\\\"\$PRO2_HOME\\\"; nohup \\\"/Applications/Antigravity.app/Contents/MacOS/Antigravity\\\" --user-data-dir=\\\"\$PRO2_HOME/Library/Application Support/Antigravity\\\" >/dev/null 2>&1 &\""

osacompile -e "$APPLET_SCRIPT" -o "$APP_TARGET"

# Copy original Antigravity icon
if [[ -f "$APP_SOURCE/Contents/Resources/icon.icns" ]]; then
    cp "$APP_SOURCE/Contents/Resources/icon.icns" "$APP_TARGET/Contents/Resources/applet.icns"
fi
# Remove Assets.car so macOS uses applet.icns
rm -f "$APP_TARGET/Contents/Resources/Assets.car"
touch "$APP_TARGET"
echo "  ✓ Launcher compiled successfully: $APP_TARGET"

echo "==> Step 4: Adding Antigravity Pro 2 to macOS Dock..."
python3 -c "
import subprocess, plistlib, random

try:
    res = subprocess.run(['defaults', 'export', 'com.apple.dock', '-'], stdout=subprocess.PIPE, check=True)
    dock = plistlib.loads(res.stdout)
    apps = dock.get('persistent-apps', [])

    # Check if already present
    already_present = any(
        'antigravity pro 2' in a.get('tile-data', {}).get('file-label', '').lower() or
        'Antigravity%20Pro%202.app' in a.get('tile-data', {}).get('file-data', {}).get('_CFURLString', '')
        for a in apps
    )

    if not already_present:
        target_idx = -1
        for idx, a in enumerate(apps):
            if a.get('tile-data', {}).get('file-label') == 'Antigravity':
                target_idx = idx
                break

        new_entry = {
            'GUID': random.randint(1000000000, 4000000000),
            'tile-type': 'file-tile',
            'tile-data': {
                'file-data': {
                    '_CFURLString': 'file:///Applications/Antigravity%20Pro%202.app/',
                    '_CFURLStringType': 15
                },
                'file-label': 'Antigravity Pro 2'
            }
        }

        if target_idx != -1:
            apps.insert(target_idx + 1, new_entry)
        else:
            apps.append(new_entry)

        dock['persistent-apps'] = apps
        subprocess.run(['defaults', 'import', 'com.apple.dock', '-'], input=plistlib.dumps(dock), check=True)
        subprocess.run(['killall', 'Dock'], check=True)
        print('  ✓ Added to Dock right next to Antigravity.')
    else:
        print('  ✓ Antigravity Pro 2 is already present in Dock.')
except Exception as e:
    print(f'  ⚠️ Notice: Could not update Dock automatically ({e}). You can manually drag the app to your Dock.')
"

echo "============================================================"
echo "🎉 Installation Complete!"
echo "============================================================"
echo "To use your second account:"
echo "1. Click 'Antigravity Pro 2' in your Dock or Applications folder."
echo "2. It will open as a clean, unauthenticated instance."
echo "3. Sign in to your secondary Google account."
echo "4. Both accounts will now run in parallel, 100% isolated."
echo "============================================================"

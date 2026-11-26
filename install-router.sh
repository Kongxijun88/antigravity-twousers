#!/usr/bin/env bash
#
# Antigravity Smart OAuth URL Router Installer for macOS
# Routes antigravity:// callbacks from the browser back to the exact instance
# (Primary, Pro 2, or Ultra) that initiated authorization.
#
set -euo pipefail

echo "============================================================"
echo "   Antigravity Smart URL Router Installer for macOS"
echo "============================================================"

if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ Error: This script is only supported on macOS."
    exit 1
fi

if ! command -v swiftc >/dev/null 2>&1; then
    echo "❌ Error: Swift compiler (swiftc) not found."
    echo "Please install Xcode Command Line Tools first: xcode-select --install"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWIFT_SRC="$SCRIPT_DIR/router/AntigravityRouter.swift"
APP_SOURCE="/Applications/Antigravity.app"
ROUTER_APP="/Applications/Antigravity Router.app"
BUNDLE_ID="com.antigravity.twousers.router"

if [[ ! -f "$SWIFT_SRC" ]]; then
    echo "❌ Error: Router source not found at $SWIFT_SRC"
    exit 1
fi

echo "==> Step 1: Compiling native macOS Smart URL Router..."
rm -rf "$ROUTER_APP"
mkdir -p "$ROUTER_APP/Contents/MacOS"
mkdir -p "$ROUTER_APP/Contents/Resources"

swiftc -O \
    -framework Cocoa \
    -framework Carbon \
    "$SWIFT_SRC" \
    -o "$ROUTER_APP/Contents/MacOS/AntigravityRouter"

echo "  ✓ Compiled native binary: $ROUTER_APP/Contents/MacOS/AntigravityRouter"

echo "==> Step 2: Writing Info.plist & app icon..."
cat << EOF > "$ROUTER_APP/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>AntigravityRouter</string>
    <key>CFBundleIconFile</key>
    <string>icon</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Antigravity Router</string>
    <key>CFBundleDisplayName</key>
    <string>Antigravity Router</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>Antigravity Router forwards antigravity:// deep links to the active Antigravity instance.</string>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>CFBundleURLName</key>
            <string>Antigravity Smart Router</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>antigravity</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

if [[ -f "$APP_SOURCE/Contents/Resources/icon.icns" ]]; then
    cp "$APP_SOURCE/Contents/Resources/icon.icns" "$ROUTER_APP/Contents/Resources/icon.icns"
fi

# Ad-hoc sign so macOS Gatekeeper / Launch Services accepts the app cleanly
codesign --force --deep --sign - "$ROUTER_APP" >/dev/null 2>&1 || true
touch "$ROUTER_APP"
echo "  ✓ Built & signed $ROUTER_APP"

echo "==> Step 3: Registering Antigravity Router as default handler for antigravity://..."
LSREG="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
"$LSREG" -f "$ROUTER_APP"

swift -e '
import Cocoa
import CoreServices

let scheme = "antigravity" as CFString
let bundleID = "com.antigravity.twousers.router" as CFString
let status = LSSetDefaultHandlerForURLScheme(scheme, bundleID)
if status == noErr {
    print("  ✓ Registered com.antigravity.twousers.router as default handler for antigravity://")
} else {
    fputs("  ⚠️ LSSetDefaultHandlerForURLScheme returned status: \(status)\n", stderr)
    exit(1)
}
if let testURL = URL(string: "antigravity://"),
   let handlerApp = NSWorkspace.shared.urlForApplication(toOpen: testURL) {
    print("  ✓ Verified active handler: \(handlerApp.path)")
}
'

echo "============================================================"
echo "🎉 Smart URL Router Installed!"
echo "============================================================"
echo "From now on, clicking 'Open Antigravity' after browser OAuth"
echo "will automatically return to the exact instance (Primary, Pro 2,"
echo "or Ultra) that initiated authorization."
echo ""
echo "Test diagnostics anytime with:"
echo "  \"$ROUTER_APP/Contents/MacOS/AntigravityRouter\" --status"
echo "============================================================"

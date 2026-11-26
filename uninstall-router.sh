#!/usr/bin/env bash
#
# Antigravity Smart OAuth URL Router Uninstaller for macOS
# Restores default antigravity:// URL scheme handling back to official Antigravity.app.
#
set -euo pipefail

echo "============================================================"
echo "   Antigravity Smart URL Router Uninstaller for macOS"
echo "============================================================"

ROUTER_APP="/Applications/Antigravity Router.app"
LSREG="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

echo "==> Step 1: Restoring antigravity:// default handler to official Antigravity..."
swift -e '
import Foundation
import CoreServices

let scheme = "antigravity" as CFString
let officialBundleID = "com.google.antigravity" as CFString
let status = LSSetDefaultHandlerForURLScheme(scheme, officialBundleID)
if status == noErr {
    print("  ✓ Restored default handler for antigravity:// to com.google.antigravity")
} else {
    fputs("  ⚠️ Warning: LSSetDefaultHandlerForURLScheme returned \(status)\n", stderr)
}
'

echo "==> Step 2: Removing $ROUTER_APP..."
if [[ -d "$ROUTER_APP" ]]; then
    "$LSREG" -u "$ROUTER_APP" >/dev/null 2>&1 || true
    rm -rf "$ROUTER_APP"
    echo "  ✓ Removed $ROUTER_APP"
else
    echo "  ✓ $ROUTER_APP not found."
fi

echo "============================================================"
echo "🎉 Restored stock macOS URL handler for Antigravity!"
echo "============================================================"

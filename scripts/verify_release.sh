#!/bin/bash
set -euo pipefail

# Verify release bundle properties: architecture, bundle id, sandbox, entitlements

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_PATH="${1:-${PROJECT_ROOT}/build/Export/Mac Menubar Calendar.app}"

if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App bundle does not exist at ${APP_PATH}"
    exit 1
fi

echo "==> Verifying App Bundle: ${APP_PATH}"

# 1. Architecture check (must be arm64)
BINARY_PATH="${APP_PATH}/Contents/MacOS/Mac Menubar Calendar"
ARCH_INFO=$(file "${BINARY_PATH}")
echo "Binary Architecture: ${ARCH_INFO}"
if ! echo "${ARCH_INFO}" | grep -q "arm64"; then
    echo "FAIL: Binary does not support arm64"
    exit 1
fi

# 2. Bundle Identifier
PLIST_PATH="${APP_PATH}/Contents/Info.plist"
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${PLIST_PATH}")
echo "Bundle Identifier: ${BUNDLE_ID}"
if [ "${BUNDLE_ID}" != "com.yuhaw0715.MacMenubarCalendar" ]; then
    echo "FAIL: Expected bundle identifier com.yuhaw0715.MacMenubarCalendar, got ${BUNDLE_ID}"
    exit 1
fi

# 3. Minimum macOS Version
MIN_VERSION=$(/usr/libexec/PlistBuddy -c "Print :LSMinimumSystemVersion" "${PLIST_PATH}")
echo "Minimum macOS Version: ${MIN_VERSION}"
if [ "${MIN_VERSION}" != "15.0" ]; then
    echo "FAIL: Expected LSMinimumSystemVersion 15.0, got ${MIN_VERSION}"
    exit 1
fi

# 4. Pure Menubar (LSUIElement == 1 or true)
UI_ELEMENT=$(/usr/libexec/PlistBuddy -c "Print :LSUIElement" "${PLIST_PATH}")
echo "LSUIElement: ${UI_ELEMENT}"
if [ "${UI_ELEMENT}" != "true" ] && [ "${UI_ELEMENT}" != "1" ]; then
    echo "FAIL: Expected LSUIElement to be true (pure menubar app)"
    exit 1
fi

# 5. Code Signature and Entitlements
echo "==> Verifying Code Signature & Entitlements..."
codesign -dv "${APP_PATH}" 2>&1
ENTITLEMENTS=$(codesign -d --entitlements - "${APP_PATH}" 2>/dev/null || true)

if ! echo "${ENTITLEMENTS}" | grep -q "com.apple.security.app-sandbox"; then
    echo "FAIL: App Sandbox entitlement is missing!"
    exit 1
fi

if ! echo "${ENTITLEMENTS}" | grep -q "com.apple.security.personal-information.calendars"; then
    echo "FAIL: Calendars entitlement is missing!"
    exit 1
fi

echo "==> ALL VERIFICATION CHECKS PASSED!"

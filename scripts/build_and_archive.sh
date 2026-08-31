#!/bin/bash
set -euo pipefail

# Build and archive script for Mac Menubar Calendar
# Supports ad-hoc ("-") or Developer ID Application code signing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
DERIVED_DATA_PATH="${BUILD_DIR}/DerivedData"
ARCHIVE_PATH="${BUILD_DIR}/MacMenubarCalendar.xcarchive"
EXPORT_DIR="${BUILD_DIR}/Export"

SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"

echo "==> Cleaning previous build artifacts..."
rm -rf "${ARCHIVE_PATH}" "${EXPORT_DIR}"

mkdir -p "${BUILD_DIR}"
mkdir -p "${EXPORT_DIR}"

echo "==> Archiving Mac Menubar Calendar (Signing Identity: ${SIGNING_IDENTITY})..."
xcodebuild archive \
    -project "${PROJECT_ROOT}/MacMenubarCalendar.xcodeproj" \
    -scheme "MacMenubarCalendar" \
    -configuration "Release" \
    -destination "generic/platform=macOS" \
    -archivePath "${ARCHIVE_PATH}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    CODE_SIGN_IDENTITY="${SIGNING_IDENTITY}" \
    CODE_SIGN_STYLE="Manual"

echo "==> Copying application bundle from archive..."
APP_BUNDLE="${ARCHIVE_PATH}/Products/Applications/Mac Menubar Calendar.app"

if [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: Application bundle not found at ${APP_BUNDLE}"
    exit 1
fi

cp -R "${APP_BUNDLE}" "${EXPORT_DIR}/"

echo "==> Build and export completed successfully: ${EXPORT_DIR}/Mac Menubar Calendar.app"

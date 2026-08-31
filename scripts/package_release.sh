#!/bin/bash
set -euo pipefail

# Package release ZIP and compute SHA-256

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXPORT_DIR="${PROJECT_ROOT}/build/Export"
RELEASE_DIR="${PROJECT_ROOT}/build/Release"
APP_PATH="${EXPORT_DIR}/Mac Menubar Calendar.app"
ZIP_NAME="MacMenubarCalendar.zip"
ZIP_PATH="${RELEASE_DIR}/${ZIP_NAME}"

if [ ! -d "${APP_PATH}" ]; then
    echo "Error: App bundle does not exist at ${APP_PATH}. Run build_and_archive.sh first."
    exit 1
fi

mkdir -p "${RELEASE_DIR}"
rm -f "${ZIP_PATH}" "${ZIP_PATH}.sha256"

echo "==> Creating Release ZIP archive..."
cd "${EXPORT_DIR}"
/usr/bin/ditto -c -k --keepParent "Mac Menubar Calendar.app" "${ZIP_PATH}"

echo "==> Computing SHA-256 checksum..."
cd "${RELEASE_DIR}"
shasum -a 256 "${ZIP_NAME}" > "${ZIP_NAME}.sha256"

SHA256_HEX=$(shasum -a 256 "${ZIP_NAME}" | awk '{print $1}')

echo "==> Release packaged successfully:"
echo "    Archive:  ${ZIP_PATH}"
echo "    SHA-256:  ${SHA256_HEX}"

#!/bin/bash
set -euo pipefail

# Generate Homebrew Cask formula for Mac Menubar Calendar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RELEASE_DIR="${PROJECT_ROOT}/build/Release"
ZIP_NAME="MacMenubarCalendar.zip"
ZIP_PATH="${RELEASE_DIR}/${ZIP_NAME}"

VERSION="${1:-1.0.0}"
TAP_DIR="${2:-/Users/yuhao/Projects/homebrew-tap}"

if [ ! -f "${ZIP_PATH}" ]; then
    echo "==> ZIP not found at ${ZIP_PATH}, building and packaging release..."
    "${SCRIPT_DIR}/build_and_archive.sh"
    "${SCRIPT_DIR}/verify_release.sh"
    "${SCRIPT_DIR}/package_release.sh"
fi

SHA256_HEX=$(shasum -a 256 "${ZIP_PATH}" | awk '{print $1}')

CASK_CONTENT=$(cat <<EOF
cask "mac-menubar-calendar" do
  version "${VERSION}"
  sha256 "${SHA256_HEX}"

  url "https://github.com/yuhaw0715/MacMenubarCalendar/releases/download/v#{version}/MacMenubarCalendar.zip"
  name "Mac Menubar Calendar"
  desc "原生 macOS Menubar 行事曆檢視器，支援深色月曆、農曆顯示與 EventKit 唯讀整合"
  homepage "https://github.com/yuhaw0715/MacMenubarCalendar"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sequoia
  depends_on arch: :arm64

  app "Mac Menubar Calendar.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Mac Menubar Calendar.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Preferences/com.yuhaw0715.MacMenubarCalendar.plist",
    "~/Library/Saved Application State/com.yuhaw0715.MacMenubarCalendar.savedState",
  ]

  caveats <<~EOS
    Mac Menubar Calendar 首次使用請先允許行事曆存取權限以載入行程。
    本 App 採用純記憶體唯讀架構，絕不修改或上傳您的行事曆資料。
  EOS
end
EOF
)

# Output to build/Release
mkdir -p "${RELEASE_DIR}"
CASK_OUTPUT="${RELEASE_DIR}/mac-menubar-calendar.rb"
echo "${CASK_CONTENT}" > "${CASK_OUTPUT}"
echo "==> Cask generated at: ${CASK_OUTPUT}"
echo "    Version: ${VERSION}"
echo "    SHA-256: ${SHA256_HEX}"

# Copy to homebrew-tap if directory exists
if [ -d "${TAP_DIR}/Casks" ]; then
    TAP_CASK_PATH="${TAP_DIR}/Casks/mac-menubar-calendar.rb"
    echo "${CASK_CONTENT}" > "${TAP_CASK_PATH}"
    echo "==> Successfully copied Cask to: ${TAP_CASK_PATH}"
fi

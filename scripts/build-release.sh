#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly RELEASES_DIR="${PROJECT_ROOT}/releases"
readonly APP_BUNDLE_NAME="Mac Menubar Calendar.app"
readonly APP_BUNDLE="${RELEASES_DIR}/${APP_BUNDLE_NAME}"
readonly APP_CONTENTS="${APP_BUNDLE}/Contents"
readonly APP_EXECUTABLE="${APP_CONTENTS}/MacOS/MacMenubarCalendar"
readonly APP_RESOURCES="${APP_CONTENTS}/Resources"
readonly INFO_PLIST_SOURCE="${PROJECT_ROOT}/MacMenubarCalendar/Resources/Info.plist"
readonly ENTITLEMENTS_SOURCE="${PROJECT_ROOT}/MacMenubarCalendar/Resources/MacMenubarCalendar.entitlements"
readonly RESOURCE_BUNDLE_NAME="MacMenubarCalendar_MacMenubarCalendar.bundle"
readonly TAP_DIR="${TAP_DIR:-/Users/yuhao/Projects/homebrew-tap}"
readonly CODESIGN_IDENTITY="${CODESIGN_IDENTITY:--}"

log() {
  printf '[MacMenubarCalendar Release] %s\n' "$1"
}

fail() {
  printf '[MacMenubarCalendar Release] 錯誤：%s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "找不到必要工具：$1"
}

for command_name in swift ditto plutil codesign shasum unzip; do
  require_command "${command_name}"
done

for required_file in "${INFO_PLIST_SOURCE}" "${ENTITLEMENTS_SOURCE}"; do
  [[ -f "${required_file}" ]] || fail "缺少必要檔案：${required_file}"
done

plutil -lint "${INFO_PLIST_SOURCE}" >/dev/null
plutil -lint "${ENTITLEMENTS_SOURCE}" >/dev/null

bundle_identifier="$(plutil -extract CFBundleIdentifier raw "${INFO_PLIST_SOURCE}")"
bundle_version="$(plutil -extract CFBundleShortVersionString raw "${INFO_PLIST_SOURCE}")"
bundle_build="$(plutil -extract CFBundleVersion raw "${INFO_PLIST_SOURCE}")"

[[ -n "${bundle_identifier}" ]] || fail "Info.plist 缺少 CFBundleIdentifier"
[[ -n "${bundle_version}" ]] || fail "Info.plist 缺少 CFBundleShortVersionString"
[[ -n "${bundle_build}" ]] || fail "Info.plist 缺少 CFBundleVersion"

readonly ARCHIVE_NAME="MacMenubarCalendar-v${bundle_version}.zip"
readonly ARCHIVE_PATH="${RELEASES_DIR}/${ARCHIVE_NAME}"

cd "${PROJECT_ROOT}"

log "建置 Mac Menubar Calendar ${bundle_version} (${bundle_build}) Release 版本..."
swift build -c release
bin_path="$(swift build -c release --show-bin-path)"
source_executable="${bin_path}/MacMenubarCalendar"
source_resource_bundle="${bin_path}/${RESOURCE_BUNDLE_NAME}"

[[ -f "${source_executable}" ]] || fail "找不到 Release executable：${source_executable}"
[[ -x "${source_executable}" ]] || fail "Release executable 沒有執行權限：${source_executable}"

log "建立標準 macOS App Bundle..."
mkdir -p "${RELEASES_DIR}"
rm -rf "${APP_BUNDLE}"
rm -f "${ARCHIVE_PATH}"
mkdir -p "${APP_CONTENTS}/MacOS" "${APP_RESOURCES}"

ditto "${source_executable}" "${APP_EXECUTABLE}"
chmod 755 "${APP_EXECUTABLE}"

# Prepare Info.plist with resolved executable name
ditto "${INFO_PLIST_SOURCE}" "${APP_CONTENTS}/Info.plist"
plutil -replace CFBundleExecutable -string "MacMenubarCalendar" "${APP_CONTENTS}/Info.plist"
plutil -replace CFBundleName -string "Mac Menubar Calendar" "${APP_CONTENTS}/Info.plist"
plutil -lint "${APP_CONTENTS}/Info.plist" >/dev/null

if [[ -d "${source_resource_bundle}" ]]; then
  ditto "${source_resource_bundle}" "${APP_RESOURCES}/${RESOURCE_BUNDLE_NAME}"
fi

# Copy localization resources directly if available
if [[ -d "${PROJECT_ROOT}/MacMenubarCalendar/Resources/zh-Hant.lproj" ]]; then
  ditto "${PROJECT_ROOT}/MacMenubarCalendar/Resources/zh-Hant.lproj" "${APP_RESOURCES}/zh-Hant.lproj"
fi
if [[ -d "${PROJECT_ROOT}/MacMenubarCalendar/Resources/en.lproj" ]]; then
  ditto "${PROJECT_ROOT}/MacMenubarCalendar/Resources/en.lproj" "${APP_RESOURCES}/en.lproj"
fi

# Copy and verify AppIcon.icns
if [[ ! -f "${PROJECT_ROOT}/MacMenubarCalendar/Resources/AppIcon.icns" ]]; then
  log "產出 AppIcon.icns..."
  swift -module-cache-path "${PROJECT_ROOT}/build/ModuleCache" "${PROJECT_ROOT}/scripts/generate_app_icon.swift"
fi
if [[ -f "${PROJECT_ROOT}/MacMenubarCalendar/Resources/AppIcon.icns" ]]; then
  ditto "${PROJECT_ROOT}/MacMenubarCalendar/Resources/AppIcon.icns" "${APP_RESOURCES}/AppIcon.icns"
fi
[[ -f "${APP_RESOURCES}/AppIcon.icns" ]] || fail "找不到 AppIcon.icns: ${APP_RESOURCES}/AppIcon.icns"

[[ -x "${APP_EXECUTABLE}" ]] || fail "App Bundle executable 沒有執行權限"

log "使用簽署 identity『${CODESIGN_IDENTITY}』簽署 App Bundle..."
codesign_args=(--force --sign "${CODESIGN_IDENTITY}")
if [[ "${CODESIGN_IDENTITY}" != "-" ]]; then
  codesign_args+=(--timestamp --options runtime)
fi

if [[ -d "${APP_RESOURCES}/${RESOURCE_BUNDLE_NAME}" ]]; then
  codesign "${codesign_args[@]}" "${APP_RESOURCES}/${RESOURCE_BUNDLE_NAME}"
fi

codesign "${codesign_args[@]}" --entitlements "${ENTITLEMENTS_SOURCE}" "${APP_BUNDLE}"
codesign --verify --deep --strict --verbose=2 "${APP_BUNDLE}"

signed_identifier="$(codesign -d --verbose=4 "${APP_BUNDLE}" 2>&1 | sed -n 's/^Identifier=//p')"
[[ "${signed_identifier}" == "${bundle_identifier}" ]] || fail "簽署後 Bundle Identifier 不一致"

log "產生 Homebrew Cask 使用的 ZIP..."
ditto -c -k --sequesterRsrc --keepParent "${APP_BUNDLE}" "${ARCHIVE_PATH}"

archive_entries="$(unzip -Z1 "${ARCHIVE_PATH}")"
[[ -n "${archive_entries}" ]] || fail "ZIP 是空的"
if printf '%s\n' "${archive_entries}" | grep -Ev '^(Mac Menubar Calendar\.app|__MACOSX)(/|$)' >/dev/null; then
  fail "ZIP 含有非預期的頂層內容"
fi

archive_sha256="$(shasum -a 256 "${ARCHIVE_PATH}" | awk '{print $1}')"
archive_size="$(du -h "${ARCHIVE_PATH}" | awk '{print $1}')"

log "產生 Homebrew Cask 定義檔..."
CASK_CONTENT=$(cat <<EOF
cask "mac-menubar-calendar" do
  version "${bundle_version}"
  sha256 "${archive_sha256}"

  url "https://github.com/yuhaw0715/MacMenubarCalendar/releases/download/v#{version}/MacMenubarCalendar-v#{version}.zip"
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
    system_command "/usr/bin/open",
                   args: ["#{appdir}/Mac Menubar Calendar.app"],
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

CASK_LOCAL_PATH="${RELEASES_DIR}/mac-menubar-calendar.rb"
echo "${CASK_CONTENT}" > "${CASK_LOCAL_PATH}"

log "發布產物建立完成！"
printf 'ZIP:      %s (%s)\n' "${ARCHIVE_PATH}" "${archive_size}"
printf 'Version:  %s (%s)\n' "${bundle_version}" "${bundle_build}"
printf 'SHA-256:  %s\n' "${archive_sha256}"
printf 'Cask:     %s\n' "${CASK_LOCAL_PATH}"

if [[ -d "${TAP_DIR}/Casks" ]]; then
  echo "${CASK_CONTENT}" > "${TAP_DIR}/Casks/mac-menubar-calendar.rb" 2>/dev/null || true
  log "已同步 Cask 至：${TAP_DIR}/Casks/mac-menubar-calendar.rb"
fi

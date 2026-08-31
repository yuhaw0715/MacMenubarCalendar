## Why

使用者需要一個能從 macOS menubar 快速瀏覽近期行程的輕量工具，不必反覆切換到完整的 Apple「行事曆」App。此工具應直接使用 Mac 已設定的行事曆來源，同時以最小權限、無遙測及本機偏好儲存保護個人行程資料。

## What Changes

- 建立只支援 Apple Silicon、最低 macOS 15 的原生純 menubar App，menubar 顯示今天日期。
- 提供從今天開始的固定 28 天、7 欄 × 4 列行事曆，支援每次前後移動 7 天及回到今天。
- 透過 EventKit 顯示 macOS 已同步的本機、iCloud、Google 等行事曆，並提供行事曆篩選、事件摘要、單日清單與事件詳情。
- App 對行程維持唯讀行為；需要後續操作時交由 Apple「行事曆」處理。
- 加入可調整及釘選的 menubar 視窗、淺色／深色外觀、繁體中文／英文及完整輔助使用支援。
- 採 App Sandbox，只啟用行事曆所需能力；不整合提醒事項、通知、第三方登入、分析、遙測、遠端錯誤回報或 App 內更新。
- 提供預設關閉的登入時啟動設定，使用公開的 Service Management API 且不要求管理員權限。
- 建立可注入假行事曆、時鐘、時區及偏好儲存的測試架構。
- 建立 ad-hoc signed ZIP 與自有 Homebrew tap 的手動發佈流程，並預留未來 Developer ID 簽署與 notarization。

## Capabilities

### New Capabilities

- `calendar-access`: EventKit 授權、行事曆來源與選擇、事件讀取、資料刷新、唯讀行為及隱私界線。
- `calendar-browsing`: Menubar 日期、28 天網格、日期導覽、事件排序與溢位、單日清單、事件詳情及開啟 Apple「行事曆」。
- `app-preferences-and-accessibility`: 視窗與釘選行為、外觀、登入時啟動、本機偏好、在地化及輔助使用。
- `distribution`: 平台限制、Sandbox、測試、ZIP Release、ad-hoc signing、Homebrew Cask 及未來正式簽署能力。

### Modified Capabilities

- 無。

## Impact

- 新增 Swift／SwiftUI macOS App 專案、必要的 AppKit 整合、EventKit 與 ServiceManagement 相依。
- 新增 App Sandbox entitlement、行事曆用途說明與 bundle identifier `com.yuhaw0715.MacMenubarCalendar`。
- 新增繁體中文及英文資源、單元測試與 UI 測試目標。
- 新增 Release 打包及簽署腳本／設定，以及外部 `yuhaw0715/homebrew-tap` 所需的 Cask 發佈契約。
- 發佈初期需由使用者逐 App 通過 Gatekeeper 核准；不得全域停用 Gatekeeper或自動移除 quarantine。

## Purpose

定義應用程式的平台、安全邊界、可驗證測試及 Homebrew 發佈契約，並確保初期 ad-hoc 簽署能平順升級為 Developer ID 正式簽署。

## Requirements

### Requirement: 限定支援平台
發佈成品 SHALL 支援 Apple Silicon 且最低需要 macOS 15，App bundle identifier MUST 為 `com.yuhaw0715.MacMenubarCalendar`。

#### Scenario: 在支援環境啟動
- **WHEN** 使用者在 Apple Silicon macOS 15 或更新版本啟動 App
- **THEN** 系統允許 App 執行並提供已規定功能

### Requirement: 採用最小 Sandbox 能力
App SHALL 啟用 App Sandbox，且只加入讀取行事曆所必要的個人資訊能力；MUST NOT 申請提醒事項、通知、檔案、相機、麥克風、定位或非必要網路能力。

#### Scenario: 檢查發佈 entitlement
- **WHEN** 維護者檢查 Release App 的簽署 entitlement
- **THEN** 結果只包含 App Sandbox、行事曆及系統運作必要項目

### Requirement: 不蒐集或傳送使用資料
App MUST NOT 整合分析、遙測、遠端錯誤回報、第三方同步或 App 內更新服務，並 SHALL 沿用 Apple「行事曆」既有通知而不另行要求通知權限。

#### Scenario: 正常使用 App
- **WHEN** 使用者瀏覽、篩選或重新整理行事曆
- **THEN** App 不向開發者或第三方服務傳送使用或事件資料

### Requirement: 使用可隔離的測試資料
系統 SHALL 允許測試替換行事曆資料、目前時間、系統時區及偏好儲存，使自動測試不存取真實個人行事曆或正式偏好。

#### Scenario: 執行自動測試
- **WHEN** 單元測試或 UI 測試執行
- **THEN** 測試使用受控假資料並可重現跨月、跨年、夏令時間、事件排序及權限狀態

### Requirement: 產生 ad-hoc signed ZIP Release
第一階段 Release SHALL 為包含 `Mac Menubar Calendar.app` 的 ZIP，App SHALL 進行 ad-hoc code signing；安裝文件 MUST 引導使用者逐 App 通過 Gatekeeper 核准，MUST NOT 全域停用 Gatekeeper或自動移除 quarantine。

#### Scenario: 首次啟動遭 Gatekeeper 阻擋
- **WHEN** 使用者安裝第一階段 Release 且 macOS 無法驗證開發者
- **THEN** 文件指示使用者從「隱私權與安全性」明確核准該 App

### Requirement: 支援自有 Homebrew Cask
維護者 SHALL 在 `yuhaw0715/homebrew-tap` 維護 `mac-menubar-calendar` Cask，定義從 `yuhaw0715/MacMenubarCalendar` GitHub Release 下載 ZIP、以 SHA-256 驗證、限定 macOS 15+ 與 Apple Silicon 架構、安裝 `Mac Menubar Calendar.app`，並宣告 `zap trash` 清理本機偏好與快取。專案 SHALL 提供 Cask 產出工具以輔助發佈流程。

#### Scenario: 使用 Homebrew 安裝
- **WHEN** 使用者執行 `brew tap yuhaw0715/tap && brew install --cask mac-menubar-calendar`
- **THEN** Homebrew 依據 Cask 下載 Release ZIP，校驗 SHA-256 並將 `Mac Menubar Calendar.app` 正確安裝至 `/Applications`

#### Scenario: 使用 Homebrew 更新
- **WHEN** 維護者發布新版並更新 Cask 的 version、url 與 sha256
- **THEN** 使用者執行 `brew upgrade --cask mac-menubar-calendar` 能順暢升級至最新版

#### Scenario: 使用 Homebrew 解除安裝
- **WHEN** 使用者執行 `brew uninstall --zap --cask mac-menubar-calendar`
- **THEN** Homebrew 移除應用程式並依 `zap trash` 宣告清理 `com.yuhaw0715.MacMenubarCalendar` 的本機偏好檔案

#### Scenario: 產出 Cask 檔案
- **WHEN** 維護者執行 `scripts/generate_cask.sh` 或 `scripts/build-release.sh`
- **THEN** 腳本自動計算 SHA-256 並產出符合 Homebrew 語法標準的 Cask 檔案

### Requirement: 預留正式簽署
建置與發佈流程 SHALL 將簽署身份及 notarization 設定參數化，使未來可改用 Developer ID Application、hardened runtime、notarization 與 stapling，而不變更 bundle identifier、App 架構或偏好儲存位置。

#### Scenario: 切換正式簽署
- **WHEN** 維護者未來提供有效 Developer ID 與 notarization 憑證設定
- **THEN** 發佈流程可產生通過 Gatekeeper 的正式簽署成品而不遷移使用者偏好

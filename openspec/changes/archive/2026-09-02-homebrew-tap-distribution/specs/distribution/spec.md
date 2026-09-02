## MODIFIED Requirements

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
- **WHEN** 維護者執行 `scripts/generate_cask.sh` 並指定版本與發佈壓縮檔
- **THEN** 腳本自動計算 SHA-256 並產出符合 Homebrew 語法標準的 Cask 檔案

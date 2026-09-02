## Context

參見 `proposal.md`。目前本專案已具備 Release 建置與打包腳本（`scripts/package_release.sh`），可產生包含 `Mac Menubar Calendar.app` 的 `MacMenubarCalendar.zip` 並計算 SHA-256。為支援 Homebrew Tap 安裝，需定義標準 Cask 規範並提供自動產出工具。

## Goals / Non-Goals

**Goals:**
- 定義標準 Homebrew Cask 格式（`mac-menubar-calendar.rb`），涵蓋版本、下載網址、SHA-256、系統限制（macOS 15+、Apple Silicon arm64）與本機偏好清理宣告（`zap trash`）。
- 實作 `scripts/generate_cask.sh` 腳本，自動讀取最新版本號與 ZIP 檔案計算校驗碼並輸出 Cask 定義。
- 支援本地 Cask 語法檢查（`brew audit`）與本機安裝驗證流程。
- 提供清晰的文件指引，包含使用者如何透過 `brew tap` / `brew install` 安裝，以及首次啟動 Gatekeeper 的核准指引。

**Non-Goals:**
- 不自動 commit/push 至外部 `yuhaw0715/homebrew-tap` 儲存庫，維持人工或授權控制。
- 不自動繞過或全域關閉 Gatekeeper。

## Decisions

### 1. Homebrew Cask 定義結構
- **格式規範**：
  ```ruby
  cask "mac-menubar-calendar" do
    version "1.0.0"
    sha256 "<computed_sha256>"

    url "https://github.com/yuhaw0715/MacMenubarCalendar/releases/download/v#{version}/MacMenubarCalendar.zip"
    name "Mac Menubar Calendar"
    desc "Native read-only macOS menubar calendar viewer with EventKit integration"
    homepage "https://github.com/yuhaw0715/MacMenubarCalendar"

    depends_on macos: ">= :sequoia"
    depends_on arch: :arm64

    app "Mac Menubar Calendar.app"

    zap trash: [
      "~/Library/Preferences/com.yuhaw0715.MacMenubarCalendar.plist",
      "~/Library/Saved Application State/com.yuhaw0715.MacMenubarCalendar.savedState",
    ]
  end
  ```
- **理由**：採用標準 Homebrew DSL，明確宣告系統需求與 Bundle ID 清理路徑，確保安裝與解除安裝皆乾淨無殘留。

### 2. Cask 產生工具 (`scripts/generate_cask.sh`)
- **機制**：傳入版本號與 ZIP 路徑（預設讀取 `build/Release/MacMenubarCalendar.zip`），透過 `shasum -a 256` 計算雜湊，輸出至 `build/Release/mac-menubar-calendar.rb`，並支援輸出至指定的 Homebrew Tap 專案路徑。

## Risks / Trade-offs

- [Risk] ad-hoc 簽署首次啟動遭 Gatekeeper 攔截 → [Mitigation] 在 README.md 詳列標準解法：前往「系統設定」>「隱私權與安全性」點擊「仍要打開」，或於終端機針對該 App 執行安全清除 quarantine。

## Why

為了讓 macOS 使用者能透過 Homebrew 快速安裝、管理與升級 Mac Menubar Calendar，需要在維護者的 Homebrew Tap 儲存庫（`yuhaw0715/homebrew-tap`）中建立標準的 Homebrew Cask（`mac-menubar-calendar`），並在專案中提供自動化 Cask 產出工具與安裝指南。

## What Changes

- **建立標準 Homebrew Cask 定義**：定義 `mac-menubar-calendar.rb` Cask 檔案，包含版本（`version`）、校驗碼（`sha256`）、下載來源（GitHub Release ZIP）、平台限制（macOS 15+、Apple Silicon arm64）、應用程式安裝位置（`Mac Menubar Calendar.app`）及完整的解除安裝清理宣告（`zap trash` 清理 `UserDefaults` 偏好設定與暫存檔）。
- **建立 Cask 產出與驗證輔助腳本**：在專案中建立 `scripts/generate_cask.sh`，可依據 Release 版本與已建置的 ZIP 自動計算 SHA-256 並輸出符合 Homebrew 規範的 Cask 檔案。
- **提供 Homebrew 安裝指南與 Gatekeeper 說明**：更新 `README.md`，提供 `brew tap yuhaw0715/tap && brew install --cask mac-menubar-calendar` 指令與第一階段 ad-hoc 簽署之安全開啟說明。

## Capabilities

### Modified Capabilities
- `distribution`: 擴充「支援自有 Homebrew Cask」之規範細節，明確定義 Cask 欄位結構（含 `depends_on`、`app`、`zap`）、SHA-256 檢驗機制及本地 `brew install --build-from-source / audit` 驗證契約。

## Impact

- 新增 `scripts/generate_cask.sh` 產出工具。
- 產出適用於 `yuhaw0715/homebrew-tap` 的 `Casks/mac-menubar-calendar.rb`。
- 更新 `README.md` 安裝指南。

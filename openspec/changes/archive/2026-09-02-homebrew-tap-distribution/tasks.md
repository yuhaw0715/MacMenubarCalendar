## 1. Cask 定義與產生工具

- [x] 1.1 建立 `scripts/generate_cask.sh` 腳本，自動讀取 Release 版本、計算 ZIP SHA-256 並生成符合標準的 `mac-menubar-calendar.rb` Cask 檔案
- [x] 1.2 產出最新 Release 版本之 `mac-menubar-calendar.rb` Cask 檔案並驗證其 Ruby 語法

## 2. 驗證與文件指引

- [x] 2.1 透過 Homebrew 語法規範或 `brew audit --cask` 驗證 Cask 檔案的相容性
- [x] 2.2 更新 `README.md`，新增 Homebrew Tap 安裝指引（`brew tap yuhaw0715/tap` / `brew install --cask mac-menubar-calendar`）與首次啟動 Gatekeeper 說明

## 3. Tap 專案整合指引

- [x] 3.1 產出適用於 `yuhaw0715/homebrew-tap` 專案的 Cask 檔案結構，並提供使用者複製或同步至 tap 儲存庫之具體指引

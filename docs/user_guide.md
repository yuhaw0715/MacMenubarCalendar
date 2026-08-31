# Mac Menubar Calendar 使用與發佈說明

## 1. 系統需求

- macOS 15.0 Sequoia 或更新版本
- Apple Silicon Mac（M1 / M2 / M3 / M4 系列處理器）

## 2. 安裝方式

### 方法 A：使用 Homebrew Cask（推薦）

1. 新增 Tap（若尚未新增）：
   ```sh
   brew tap yuhaw0715/tap
   ```
2. 安裝 Mac Menubar Calendar：
   ```sh
   brew install --cask mac-menubar-calendar
   ```
3. 升級至最新版本：
   ```sh
   brew upgrade --cask mac-menubar-calendar
   ```
4. 移除應用程式：
   ```sh
   brew uninstall --cask mac-menubar-calendar
   ```

### 方法 B：直接下載 ZIP 安裝

1. 從 GitHub Releases 下載 `MacMenubarCalendar.zip`。
2. 解壓縮後將 `Mac Menubar Calendar.app` 拖移至 `/Applications`（應用程式）資料夾。

---

## 3. 首次啟動與 Gatekeeper 手動核准說明

第一階段版本使用本機 ad-hoc 簽署。當您首次啟動應用程式時，macOS Gatekeeper 可能會顯示「無法驗證開發者」的安全性提示。

請依照以下標準 macOS 逐 App 核准流程開啟：

1. 開啟 macOS **「系統設定」 (System Settings)**。
2. 點選左側選單的 **「隱私權與安全性」 (Privacy & Security)**。
3. 向下滾動至 **「安全性」 (Security)** 區塊。
4. 您會看到提示：「已阻擋『Mac Menubar Calendar』，因為它並非來自已識別的開發者」。
5. 點擊 **「仍要打開」 (Open Anyway)**。
6. 在彈出的系統確認對話框中輸入您的 Mac 密碼或使用 Touch ID 確認。

> [!NOTE]
> 本應用程式遵循最小權限原則與 Apple Sandbox 安全規範，絕不要求關閉系統 Gatekeeper 或執行繞過全域安全防護的指令。

---

## 4. 行事曆存取權限說明

- 當您首次點擊 Menubar 圖示開啟月曆時，系統將要求行事曆存取權限。
- 由於 macOS EventKit API 限制，讀取行程需申請「完整存取權」，但本應用程式在架構層嚴格維持**唯讀**，不會建立、修改或刪除任何行程，所有行程內容亦只保留於記憶體中，絕不儲存至硬碟或雲端。
- 若您需要調整授權，可隨時至「系統設定」>「隱私權與安全性」>「行事曆」進行開啟或關閉。

---

## 5. 發佈與維護手冊 (For Maintainers)

### 建立 Release 建置與封裝

```sh
# 1. 執行單元與 UI 測試
xcodebuild test -project MacMenubarCalendar.xcodeproj -scheme MacMenubarCalendar -destination 'platform=macOS,arch=arm64' -derivedDataPath .build/DerivedData

# 2. 建置 Release Archive 並匯出 .app
./scripts/build_and_archive.sh

# 3. 驗證 App 架構與 Entitlements
./scripts/verify_release.sh

# 4. 打包 ZIP 與產生 SHA-256 Checksum
./scripts/package_release.sh
```

### 未來切換 Developer ID 與 Notarization

當取得 Apple Developer 憑證時，可透過環境變數傳入簽署身份：

```sh
export SIGNING_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
./scripts/build_and_archive.sh
# 執行 xcrun notarytool submit 與 stapler
xcrun notarytool submit build/Release/MacMenubarCalendar.zip --keychain-profile "AC_PASSWORD" --wait
xcrun stapler staple "build/Export/Mac Menubar Calendar.app"
```

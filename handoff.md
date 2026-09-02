# Mac Menubar Calendar - 專案交接文件 (Handoff)

**更新時間**：2026-09-02  
**當前版本**：v1.1.0  
**專案位置**：`/Users/yuhao/Projects/MacMenubarCalendar`  
**Homebrew Tap 儲存庫**：`yuhaw0715/homebrew-tap` (`/Users/yuhao/Projects/homebrew-tap`)  
**Skill 專案儲存庫**：`yuhaw0715/YuhaoSkills` (`/Users/yuhao/Projects/YuhaoSkills`)

---

## 📌 專案概況與重要限制

- **架構**：macOS 15+、純 Apple Silicon (arm64)、Swift 6 + SwiftUI、App Sandbox 啟用。
- **建置支援**：同時支援 SPM (`swift build`, `swift run`, `swift test`) 與 Xcode (`.xcodeproj`)。
- **發佈工具**：`scripts/build-release.sh`（一鍵 Release 編譯、組裝標準 `.app`、簽署、產出 `releases/MacMenubarCalendar-v{version}.zip`、計算 SHA-256 並自動更新 `homebrew-tap/Casks/mac-menubar-calendar.rb`）。
- **隱私原則**：EventKit 嚴格唯讀，純記憶體保存行程，偏好儲存於本機 `UserDefaults`，零遙測。

---

## 🚀 最近已完成的里程碑

1. **語言切換 (`language-switching`)**：
   - 支援「跟隨系統」、「繁體中文」與「English」。跟隨系統時若系統語言為中文（`zh`）自動切換繁體中文，其餘語言自動回退英文。
   - 選單列雙層圖示（`9月`/`02` 或 `SEP`/`02`）與介面即時動態連動。
2. **Homebrew Tap 發布 (`v1.0.0`)**：
   - 建立並發布 GitHub Release `v1.0.0`。
   - 於 `yuhaw0715/homebrew-tap` 建立 `Casks/mac-menubar-calendar.rb`，使用者可透過 `brew tap yuhaw0715/tap && brew install --cask mac-menubar-calendar` 安裝。
   - 修復獨立 `.app` 啟動時 SwiftPM 資源包（`Bundle.module`）的路徑載入問題。
3. **週對齊 28 天網格與一週起始日設定 (`week-aligned-grid`)**：
   - 完成 `FirstDayOfWeek`（跟隨系統、星期日、星期一）列舉與 `effectiveWeekday` 計算。
   - `CalendarGridCalculator` 支援 `startOfWeek`、週對齊 28 天網格、動態星期標頭排序與以第一格為基準的年月標題。
   - `PreferencesStoreProtocol`、`AppPreferencesStore`、`MockPreferencesStore` 支援本機偏好持久化。
   - `SettingsView` 新增一週起始日分段選擇器，切換即時連動網格與標頭。
   - 繁中與英文在地化多語系字串支援完成。
   - 全套單元測試與 UI 測試（`swift test`、`xcodebuild test`）36 項測試 100% 通過。

---

## 🎯 後續步驟 (Next Steps)

1. **歸檔 OpenSpec 變更**：
   - 執行 OpenSpec 歸檔 (`openspec-archive-change`) 將 `week-aligned-grid` 變更歸檔至 `openspec/changes/archive/` 並同步更新主規格 `openspec/specs/`。
2. **版本發佈準備 (v1.1.0)**：
   - 更新 `Info.plist` 版本號為 `1.1.0`。
   - 經使用者明確授權後執行 `./scripts/build-release.sh` 打包與更新 Homebrew Tap。

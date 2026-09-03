## Context

目前 Mac Menubar Calendar 缺乏專屬應用程式圖示（App Icon）。在使用者確認採用「方案 3A（側邊紅標籤活頁日曆風）」後，系統需要一套兼具離線靜態 `.icns` 建置與執行時即時動態更新的渲染架構。

動機請參見 `proposal.md`，行為契約請參見 `specs/app-icon/spec.md` 與 `specs/distribution/spec.md`。

## Goals / Non-Goals

**Goals:**
- 建立具備高解析度向量精度的 `AppIconRenderer`，以 CoreGraphics / AppKit 程式化繪製方案 3A 視覺元素。
- 支援繁體中文（`9月` / `週四`）與英文（`SEP` / `THU`）動態排版。
- 支援離線透過 macOS 原生 `iconutil` 將多尺寸 PNG 產出為標準 `AppIcon.icns`，並納入 `scripts/build-release.sh` 發布流程。
- 建立運行時動態更新機制，在啟動、跨日（午夜 00:00）、時區變更、休眠喚醒及語言切換時，自動將當天日期渲染為 `NSApplication.shared.applicationIconImage`。

**Non-Goals:**
- 不改變 App 既有的 `LSUIElement = true` 屬性（本 App 仍維持純選單列 App 定位）。
- 不修改既有的選單列圖示 `MenubarIconRenderer`（選單列雙層小圖示維持原有規格）。
- 不使用任何外部第三方圖片處理或向量字型轉換函式庫。

## Decisions

### Decision 1: 程式化 CoreGraphics 繪製 vs. 靜態預製點陣圖
- **選擇**：使用純 CoreGraphics / AppKit 程式化即時繪製。
- **理由**：
  1. 軟體僅有數 MB，無需為 365 天與雙語系打包數百張點陣圖檔。
  2. 程式碼渲染可確保在任何 DPI / 縮放下維持向量級邊緣與高光精度。
  3. 可隨當前系統字體、語言模式與動態日期無縫即時變更。
- **替代方案**：預製 12 個月份靜態圖檔。缺點是日期與星期幾無法動態對齊，容量亦會增加。

### Decision 2: 離線靜態 `.icns` 產出管線
- **選擇**：提供一個小型的圖示建置指令/腳本（如 `scripts/generate_app_icon.swift`），生成包含 16x16 至 1024x1024 各尺寸的 `AppIcon.iconset`，再使用 macOS 系統自帶的 `iconutil -c icns` 產生標準 `AppIcon.icns` 置於 `MacMenubarCalendar/Resources/`。
- **理由**：`iconutil` 為 macOS Command Line Tools 內建工具，不需安裝額外 CLI 依賴即可於本機及 CI 建置環境執行。

### Decision 3: 即時動態圖示生命週期管理
- **選擇**：在 `App` 啟動階段或 `StatusItemController` 初始化時掛載圖示生命週期監聽：
  - 監聽 `NSCalendarDayChanged`（午夜換日）。
  - 監聽 `NSSystemTimeZoneDidChange`（時區切換）。
  - 監聽 `NSWorkspace.didWakeNotification`（筆電自休眠喚醒時補正）。
  - 監聽 `AppPreferencesStore` 的語言變更廣播。
- **理由**：確保即使 Mac 蓋上螢幕隔日喚醒，圖示也能瞬間同步至當日真實日期與星期。

## Risks / Trade-offs

- **[Risk] 休眠過夜可能錯過午夜的 `NSCalendarDayChanged` 通知**
  - **Mitigation**: 額外監聽 `NSWorkspace.didWakeNotification`，在每次休眠喚醒時強制觸發一次圖示檢查與重繪。
- **[Risk] 小尺寸（如 16x16 或 32x32）下左側文字不易辨識**
  - **Mitigation**: 在渲染引擎中實作尺寸最佳化：大尺寸（128 以上）完整繪製穿孔眼與細撕頁線；極小尺寸（16~32）適度增粗文字筆畫並加強顏色對比度。

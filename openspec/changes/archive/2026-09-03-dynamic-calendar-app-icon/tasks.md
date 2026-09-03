## 1. 核心圖示渲染引擎 (AppIconRenderer)

- [x] 1.1 建立 `AppIconRenderer.swift` 並實作方案 3A「側邊紅標籤活頁日曆」繪圖邏輯，包含 Squircle 圓角底板、左側日曆紅索引列、撕頁縫線、3 組金屬活頁環及右側大日期，執行單元測試確認產出非空 NSImage。
- [x] 1.2 於 `AppIconRenderer` 實作中英文多語系切換邏輯（中文：`9月` / `週四`；英文：`SEP` / `THU`），撰寫單元測試驗證不同語言設定下的字串與排版輸出。
- [x] 1.3 實作多解析度縮放降採樣支援（16x16 至 1024x1024 各級別），撰寫測試驗證各尺寸產出的圖片維度符合規範。

## 2. 執行時即時動態更新 (Live Dynamic Updating)

- [x] 2.1 整合圖示動態更新控制器，監聽系統午夜換日（`NSCalendarDayChanged`）、時區變更（`NSSystemTimeZoneDidChange`）、筆電休眠喚醒（`NSWorkspace.didWakeNotification`）及語言偏好變更，即時更新 `NSApplication.shared.applicationIconImage`。
- [x] 2.2 撰寫動態圖示更新機制的單元測試，透過 Mock 通知驗證觸發時正確重新呼叫渲染並套用至系統圖示。

## 3. 靜態 .icns 資源生成與專案設定

- [x] 3.1 建立圖示產出腳本 `scripts/generate_app_icon.swift`，產生各尺寸 PNG 並透過系統 `iconutil` 編譯產出 `MacMenubarCalendar/Resources/AppIcon.icns`。
- [x] 3.2 更新 `MacMenubarCalendar/Resources/Info.plist` 加入 `CFBundleIconFile` 指向 `AppIcon`，並確保 Xcode 專案與 SPM 資源配置完整。

## 4. 發佈建置與驗證 (Build & Verification)

- [x] 4.1 更新 `scripts/build-release.sh`，在 App Bundle 組裝階段確保 `AppIcon.icns` 被完整複製至 `Contents/Resources/` 並包含於 codesign 簽署校驗中。
- [x] 4.2 執行完整測試套件（`swift test`）與 Release 打包腳本（`scripts/build-release.sh`），驗證 App Bundle 簽署有效性與圖示檔案存在。

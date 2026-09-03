## Why

目前 Mac Menubar Calendar 缺少專屬的應用程式圖示（App Icon），在 Finder、Launchpad、系統設定「登入項目」及「隱私權與安全性 > 行事曆」授權清單中僅顯示 macOS 預設的通用空白執行檔圖示，缺乏品牌識別度與精緻度。

透過導入基於方案 3A（側邊紅標籤活頁日曆風）的專屬應用程式圖示，並支援在執行時即時反映當前「月份、日期與星期幾」以及跟隨語言設定切換中英文，可大幅提升軟體體驗與原生 macOS 整合度。

## What Changes

- **新增應用程式圖示渲染核心（`AppIconRenderer`）**：
  - 實作方案 3A「側邊紅標籤活頁日曆風」CoreGraphics / AppKit 繪製引擎。
  - 支援繪製 1024x1024 高解析度畫布，包含左側經典日曆紅索引書脊、右側象牙白紙頁、頂部金屬穿孔眼與活頁裝訂環、撕頁縫線、以及超大圓角粗體日期數字。
  - 支援多語系佈局切換：中文（`9月` / `週四`）與英文（`SEP` / `THU`）。
- **支援執行中即時動態更新（Live Dynamic Updating）**：
  - 在 App 運行期間（包括啟動時、午夜換日 `NSCalendarDayChanged`、時區變更或語言偏好變更時），自動重新渲染當前日期並動態套用至 `NSApplication.shared.applicationIconImage`。
- **打包與靜態資源支援（Static .icns Generation）**：
  - 建立離線圖示生成工具，產出包含 16x16、32x32、64x64、128x128、256x256、512x512、1024x1024（含 @2x Retina）的完整 `AppIcon.icns` 資源檔。
  - 更新 `Info.plist` 加入 `CFBundleIconFile` 指向 `AppIcon`。
  - 更新 `scripts/build-release.sh`，在發布建置流程中確保 `AppIcon.icns` 正確複製至 `Mac Menubar Calendar.app/Contents/Resources/` 並正確簽署。

## Capabilities

### New Capabilities
- `app-icon`: 定義應用程式圖示（App Icon）的視覺規範、方案 3A 佈局、中英文多語系動態渲染，以及執行中即時換日更新機制。

### Modified Capabilities
- `distribution`: 於 App Bundle 與 Release 建置發佈流程中加入靜態 `AppIcon.icns` 資源、`Info.plist` 圖示設定與程式碼簽署驗證。

## Impact

- **Affected Code**：
  - 新增 `MacMenubarCalendar/Core/Logic/AppIconRenderer.swift`
  - 修改 `MacMenubarCalendar/App/AppDelegate.swift` 或 `StatusItemController.swift`（掛載即時動態圖示更新與通知監聽）
  - 修改 `MacMenubarCalendar/Resources/Info.plist`（新增 `CFBundleIconFile`）
  - 新增或更新靜態圖示資源 `MacMenubarCalendar/Resources/AppIcon.icns`
  - 修改 `scripts/build-release.sh`（確保圖示納入 Release Bundle）
- **Dependencies**：純原生 AppKit / CoreGraphics，無新增第三方依賴。
- **Breaking Changes**：無破壞性變更。

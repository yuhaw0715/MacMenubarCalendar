## 1. 資料模型與偏好設定層

- [x] 1.1 建立 `FirstDayOfWeek` 列舉模型，實作 `effectiveWeekday(calendar:)` 判定與在地化標籤
- [x] 1.2 更新 `PreferencesStoreProtocol`、`AppPreferencesStore` 與 `MockPreferencesStore` 支援 `firstDayOfWeek` 儲存與讀取

## 2. 核心計算與狀態管理

- [x] 2.1 更新 `CalendarGridCalculator` 實作週起始日計算 `startOfWeek`、週對齊 28 天網格產出、動態星期標頭清單與以第一格為基準之月份標題
- [x] 2.2 更新 `CalendarViewModel` 加入 `firstDayOfWeek` 狀態管理、`setFirstDayOfWeek` 方法與網格重算連動

## 3. UI 介面與偏好設定面板

- [x] 3.1 在 `SettingsView` 的一般設定區塊中新增「一週第一天」分段選擇器（跟隨系統、星期日、星期一）
- [x] 3.2 更新 `HeaderControlsView` 與 `CalendarGridView` 的星期欄位標頭與頂部年月標題渲染
- [x] 3.3 新增並更新在地化多語系字串（`zh-Hant` 與 `en`）

## 4. 測試與驗證

- [x] 4.1 更新 `CalendarGridCalculatorTests` 驗證週對齊（週日/週一/跟隨系統）、28 天跨月/跨年及月份標題
- [x] 4.2 擴充 `PreferencesTests` 驗證 `firstDayOfWeek` 讀寫與本機持久化
- [x] 4.3 執行 `swift test`、`xcodebuild test` 與全套自動化測試

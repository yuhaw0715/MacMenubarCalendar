## Why

原本 28 天網格以「今天」作為第一格，導致星期欄位標頭隨當天日期浮動（例如週三為第一欄），不符合一般使用者習慣的標準整週月曆檢視模式。此變更將月曆網格改為「週對齊（以本週起始日為第一格）」，並提供一週第一天（跟隨系統、星期日、星期一）的偏好設定。

## What Changes

- **以本週起始日作為 28 天網格第一天**：開啟 App 或點擊「今天」時，網格左上角第一格錨定為「包含今天的本週起始日」（例如今天是 9/2 週三且起始日為週日，第一格即為 8/30 週日），連續顯示 4 週共 28 天。「今天」紅色圓形徽章自然對齊至第一列對應欄位（如第 4 欄）。
- **新增一週起始日偏好設定 (`FirstDayOfWeek`)**：
  - 支援「跟隨系統」、「星期日」、「星期一」三種模式，預設為「跟隨系統」。
  - 於「偏好設定」面板中提供分段選擇器，切換時即時更新月曆網格與星期標頭，並本機持久化保存於 `UserDefaults`。
- **動態星期標頭排列**：星期標頭依有效起始日動態排列（週日模式為：日、一、二、三、四、五、六；週一模式為：一、二、三、四、五、六、日）。
- **頂部月份標題規則調整**：頂部年月標題（如「2026年 8月」）一律以網格「第一列第一天（第一格）」所在的年月為準。
- **週導覽推移**：點擊「上一週 `<`」與「下一週 `>`」以 7 天（1 整週）平滑平移，點擊「今天」重設回包含今天的本週起始日。

## Capabilities

### Modified Capabilities
- `calendar-browsing`: 修改 28 天網格的起始日錨定規則（改為本週第一天）、星期欄位標頭排序、今天位置對齊及月份標題基準。
- `app-preferences-and-accessibility`: 擴充偏好設定與本機儲存，新增「一週起始日」設定（跟隨系統、星期日、星期一）。

## Impact

- 核心邏輯：更新 `CalendarGridCalculator` 計算邏輯，新增週起始日錨定演算法。
- 偏好設定：`PreferencesStoreProtocol`、`AppPreferencesStore`、`MockPreferencesStore` 新增 `firstDayOfWeek`。
- View Model：`CalendarViewModel` 新增 `firstDayOfWeek` 狀態與即時刷新。
- UI：`SettingsView` 新增一週起始日選擇器、`HeaderControlsView` 標題更新。
- 測試：更新 `CalendarGridCalculatorTests`、`PreferencesTests` 並新增一週起始日與週對齊單元測試。

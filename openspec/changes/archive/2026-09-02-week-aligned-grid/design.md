## Context

參見 `proposal.md`。目前 `CalendarGridCalculator` 採用以 `currentDate` 直接作為第 1 天的 28 天連續計算方式，使得頂部星期標頭隨當天浮動。本設計將計算核心調整為週對齊網格，並引進一週起始日自訂偏好。

## Goals / Non-Goals

**Goals:**
- 建立 `FirstDayOfWeek` 列舉（`system`、`sunday`、`monday`），支援取得有效起始日（1=週日、2=週一）。
- 升級 `CalendarGridCalculator`：
  - 提供 `startOfWeek(for:firstDayOfWeek:calendar:)` 正確計算包含基準日之週起始日。
  - `calculateGridDates` 回傳以週起始日起算的 28 天連續日期。
  - `weekdayHeaders` 回傳依週起始日排序的 7 個在地化星期符號（例如週日開始為 `["週日", "週一", ...]`）。
  - `monthTitle` 以網格第 1 格所在年月渲染「2026年 8月」或「August 2026」。
- 整合 `PreferencesStoreProtocol` 與 `SettingsView`，支援偏好儲存與即時介面刷新。

**Non-Goals:**
- 不改變 7 欄 × 4 列（28 天）的整體版面尺寸與排版密度。

## Decisions

### 1. `FirstDayOfWeek` 列舉設計
```swift
public enum FirstDayOfWeek: String, CaseIterable, Codable, Sendable {
    case system
    case sunday
    case monday

    public func effectiveWeekday(calendar: Calendar = .current) -> Int {
        switch self {
        case .system:
            return calendar.firstWeekday
        case .sunday:
            return 1 // Sunday
        case .monday:
            return 2 // Monday
        }
    }
}
```

### 2. 週起始日計算演算法
透過 `(currentWeekday - targetFirstWeekday + 7) % 7` 計算回推天數，確保在任何時區、閏年及日光節約時間轉換下均能精確取得週首日。

### 3. 月份標題與導覽基準
- 頂部標題一律格式化 `gridDates.first`（第 1 格）之年月。
- 點擊「上一週」/「下一週」以 7 天整週遞增/遞減，點擊「今天」重設回包含今天之週起始日。

## Risks / Trade-offs

- [Risk] 跨月、跨年時第 1 格可能落在前一個月（如 8/30 週日） → [Mitigation] 依使用者決策，頂部標題明確顯示第 1 格所在月份（如「8月」），日期格內的國曆與農曆標籤完整顯示日期（如 8/31、9/1 等），視覺清晰無歧義。

## Context

參見 `proposal.md`。目前 App 具備 `AppStrings` 多語系字串查詢模組與 `MenubarIconRenderer` 選單列雙層圖示繪製引擎，但尚未提供顯式的語言選擇偏好與自動中文/英文回退模型。

## Goals / Non-Goals

**Goals:**
- 建立 `AppLanguage` 列舉（`system`、`zhHant`、`en`），支援 `Codable`、`Identifiable` 與 `UserDefaults` 本機持久化。
- 實作語言判定解析器：當設定為 `system` 時，讀取 macOS 系統首選語言（`Locale.preferredLanguages`），若為中文（`zh` 開頭）則生效 `zh-Hant`，其他語言一律回退至 `en`。
- 在 `CalendarViewModel` 與 `PreferencesStoreProtocol` 中整合 `appLanguage` 狀態管理。
- 讓 `AppStrings`、`MenubarIconRenderer`、`DayCellView`（農曆標頭判斷）、`HeaderControlsView` 及 `StatusItemController` 統一依據當前生效語言更新。
- 在 `SettingsView` 的「一般設定」區塊中新增語言切換選單。

**Non-Goals:**
- 不引入第三方在地化框架或外部雲端翻譯服務。
- 不修改使用者 Apple「行事曆」資料庫中的原生事件標題、地點或備註。

## Decisions

### 1. 建立集中式語言模型 `AppLanguage`
- **方案**：定義 `AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable`，包含 `.system`、`.zhHant`、`.en`。
- **理由**：與現有的 `AppearanceMode` 架構保持一致，便於 SwiftUI Picker 綁定與 `UserDefaults` 存取。

### 2. 生效語言解析邏輯 (`effectiveLocale`)
- **方案**：
  ```swift
  public var effectiveLocale: Locale {
      switch self {
      case .zhHant:
          return Locale(identifier: "zh-Hant")
      case .en:
          return Locale(identifier: "en")
      case .system:
          let preferred = Locale.preferredLanguages.first ?? ""
          if preferred.starts(with: "zh") {
              return Locale(identifier: "zh-Hant")
          } else {
              return Locale(identifier: "en")
          }
      }
  }
  ```
- **理由**：單一職責且可測試，確保在跟隨系統時嚴格執行「中文走中文，非中文一律回退英文」之規則。

### 3. 即時響應與選單列重繪機制
- **方案**：使用者在 `SettingsView` 變更 `appLanguage` 時，`CalendarViewModel` 立即更新已發布屬性，`StatusItemController` 監聽該變更並即刻使用新語言重繪 Menubar 圖示，SwiftUI View 自動依據新 ViewModel 狀態重新渲染。

## Risks / Trade-offs

- [Risk] 系統語言在 App 運行中被使用者由 macOS 系統設定變更 → [Mitigation] 透過 `SystemNotificationWatcher` 監聽 `NSCurrentLocaleDidChange` 通知，自動觸發重新計算並更新 UI。

## Why

目前 Mac Menubar Calendar 僅能隱式跟隨系統地區設定，使用者無法在偏好設定中主動切換 App 的顯示語言。為提供更靈活的使用體驗，需提供「語言手動與自動切換功能」：在跟隨系統時，系統語言為中文自動切換至中文，非中文自動回退至英文；同時允許使用者在偏好設定中手動鎖定為繁體中文或英文。

## What Changes

- **偏好設定新增語言選項**：在「偏好設定」面板中加入「語言」設定項目，提供「跟隨系統 (System)」、「繁體中文 (Traditional Chinese)」、「英文 (English)」三種選項。
- **自動語言判定規則**：在「跟隨系統」模式下，若 macOS 首選語言為中文系（`zh` / `zh-Hant` / `zh-Hans` / `zh-TW` / `zh-HK` / `zh-CN` 等），介面與選單列圖示自動顯示中文；若為其他語言，自動切換至英文。
- **手動語言切換與即時響應**：使用者在偏好設定切換語言時，無需重啟 App，主視窗、導覽按鈕、行程詳情、偏好設定面板、右鍵選單及選單列雙層圖示即時更新為所選語言。
- **本機偏好保存**：語言偏好設定（`appLanguage`）僅保存於本機 `UserDefaults`，符合純本機保存與隱私原則。

## Capabilities

### Modified Capabilities
- `app-preferences-and-accessibility`: 擴充在地化介面與偏好保存需求，定義語言選擇選項（跟隨系統、繁體中文、英文）與自動/手動判定邏輯。

## Impact

- `Core/Models/AppLanguage.swift`: 新增語言列舉模型（`.system`, `.zhHant`, `.en`）。
- `Core/Protocols/PreferencesStoreProtocol.swift` 與 `Core/Services/AppPreferencesStore.swift`: 新增 `appLanguage` 偏好儲存與讀取。
- `Core/Logic/AppStrings.swift` 與 `Core/Logic/MenubarIconRenderer.swift`: 支援依指定之 `AppLanguage` 解析多語系字串與繪製雙層選單列圖示。
- `Presentation/ViewModels/CalendarViewModel.swift`: 支援 `appLanguage` 變更與即時 UI 廣播。
- `Presentation/Views/SettingsView.swift`: 新增語言切換 Picker 控制元件。

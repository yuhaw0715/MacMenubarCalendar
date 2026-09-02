## 1. 資料模型與偏好設定層

- [x] 1.1 建立 `AppLanguage` 列舉模型，實作 `effectiveLocale` 判定邏輯（中文走繁體中文，非中文一律回退英文）與在地化標籤
- [x] 1.2 更新 `PreferencesStoreProtocol`、`AppPreferencesStore` 與 `MockPreferencesStore` 支援 `appLanguage` 偏好儲存與讀取

## 2. 核心邏輯與字串渲染層

- [x] 2.1 更新 `AppStrings` 支援依傳入之 `AppLanguage` 解析多語系字串與 Fallback 機制
- [x] 2.2 更新 `MenubarIconRenderer` 支援傳入 `AppLanguage` 繪製雙層月份/日期 Template 圖示
- [x] 2.3 更新 `CalendarViewModel` 加入 `appLanguage` 狀態管理、切換方法與系統 Locale 變更監聽

## 3. UI 介面與選單列整合

- [x] 3.1 在 `SettingsView` 的一般設定區塊中新增「語言」切換選擇器（跟隨系統、繁體中文、英文）
- [x] 3.2 更新 `StatusItemController` 監聽語言變更，即時重繪選單列圖示與右鍵快捷選單
- [x] 3.3 確保 `HeaderControlsView` 與 `DayCellView` 等視圖在手動切換語言時即時連動更新

## 4. 測試與驗證

- [x] 4.1 新增 `AppLanguageTests` 單元測試，驗證中文、英文及其他未支援語言的自動回退與手動指定邏輯
- [x] 4.2 擴充 `PreferencesTests` 驗證語言偏好的讀寫與本機持久化
- [x] 4.3 執行 `swift test`、`xcodebuild test` 與全套驗證

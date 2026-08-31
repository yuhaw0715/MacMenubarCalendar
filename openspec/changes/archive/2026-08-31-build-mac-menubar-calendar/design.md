## Context

目前 repository 只有 OpenSpec 設定與已確認的需求文件，尚無 App 程式碼。完整動機與產品範圍見 `proposal.md`，可觀察行為見四份能力規格。

主要技術限制是：EventKit 沒有唯讀授權層級；讀取事件必須取得 full access，但產品行為必須嚴格唯讀。App 同時需要 App Sandbox、純 menubar activation policy、可釘選視窗、登入時啟動、可測試日期運算，以及未簽署初期發佈與未來 Developer ID 發佈兩條路徑。

## Goals / Non-Goals

**Goals:**

- 讓 EventKit、時間、偏好與系統操作都能以介面隔離並接受測試替身。
- 讓 UI 狀態不直接持有或修改 EventKit 可寫物件，從結構上降低誤寫風險。
- 以單一 macOS App target 完成 menubar 與登入時啟動，不引入具高權限的 helper、daemon 或第三方服務。
- 讓 ad-hoc 與未來 Developer ID 簽署共用相同 archive 與打包流程。

**Non-Goals:**

- 不建立可跨平台的抽象 UI，也不為 Intel 建置。
- 不建立事件資料庫、同步引擎、遠端後端或自動更新服務。
- 不繞過 macOS TCC、Sandbox 或 Gatekeeper 安全機制。

## Decisions

### 1. 使用 SwiftUI App 狀態層搭配小型 AppKit 視窗控制器

主要畫面、設定、詳情及在地化採 SwiftUI。Menubar status item、非釘選 transient panel 與釘選後可調整的 floating panel 由一個 AppKit 視窗協調器管理，並將同一個 SwiftUI root view 嵌入視窗。這比只用 `MenuBarExtra` 更能控制可調整尺寸、失焦關閉及釘選狀態，又避免將所有畫面改寫成 AppKit。

替代方案是只用 `MenuBarExtra(.window)`；其視窗生命週期與釘選／resize 控制可能不足，因此列為技術 spike 的比較基準，而不是預設架構。

### 2. 將 EventKit 映射為不可變的應用程式模型

建立 `CalendarProviding` 類型的唯讀介面，只暴露授權狀態、行事曆摘要、指定範圍事件摘要及變更通知。EventKit adapter 取得資料後立即映射為不含 save/remove 能力的不可變值模型；View model 與 View 不接觸 `EKEventStore` 或 `EKEvent`。

如此即使系統授予 full access，產品層也沒有寫入入口。替代方案是直接在 View model 使用 EventKit，程式較少但較難證明唯讀、較難測試，也容易讓 EventKit 物件跨生命週期使用，因此不採用。

### 3. 日期範圍採半開區間與可注入時間來源

28 天查詢使用系統 Calendar 依目前時區建立 `[startOfDay, startOfDay + 28 days)` 半開區間，避免月底、閏年與夏令時間用固定秒數計算造成錯誤。前後導覽改變 start day 7 個 calendar days；每次重新打開重設為 clock 提供的今天。

事件映射層將跨日事件分派至區間內所有相交日期；同日先以全天狀態排序，再以開始時間及穩定識別值排序。Clock、Calendar 與時區通知皆可注入。

### 4. 只在記憶體持有事件，偏好使用本機儲存

目前畫面事件只保存在 observable state，刷新時整批替換。偏好以 UserDefaults-compatible store 保存，但事件內容絕不寫入其中。行事曆選擇以穩定識別碼集合保存，重新整理來源時清除失效項並將新來源預設為選取。

不採 Core Data、SwiftData 或 iCloud，因為需求沒有離線資料庫或跨裝置同步，加入它們會擴大資料殘留與權限面。

### 5. 權限狀態明確建模

啟動時只讀取授權狀態；在使用者第一次打開需要事件的畫面且狀態為 not determined 時才要求 `requestFullAccessToEvents`。拒絕與 restricted 狀態進入可恢復的空畫面，提供說明及前往系統隱私設定入口，不持續重試。

Info.plist 的用途文字必須明說 EventKit 要求完整存取才能讀取，但 App 不會修改資料。Sandbox entitlement 僅加入 calendar personal-information 能力。

### 6. 系統整合包在窄介面後

登入時啟動透過 `SMAppService.mainApp` 的 register／unregister／status，並以 `LoginItemManaging` 介面隔離。開啟 Apple「行事曆」也由 `CalendarOpening` 介面封裝：先技術驗證公開 URL／Apple Event 能否定位單一事件；不能時只開啟事件日期。

任何定位方案若要求額外 Automation 權限，預設不採用，直接使用日期降級，避免違反最小權限。

### 7. 輔助使用由語意資料而非畫面顏色產生

每個日期格與事件摘要提供結構化 accessibility label/value/hint。行事曆名稱、全天／已拒絕狀態以文字語意輸出。日期格的可見事件數由實際可用高度及量測列高計算；文字放大時減少摘要數量並保留可操作的溢位入口。

### 8. 發佈流程分離 archive、sign、package

Release 流程分為可重現的 Release archive、簽署驗證、ZIP 打包、checksum 四階段。簽署設定接受 ad-hoc `-` 或未來 Developer ID identity；notarization 與 stapling 僅在提供必要憑證時啟用。每階段驗證 bundle identifier、架構、最低系統版本、entitlement 與 code signature。

Homebrew Cask 不執行 preflight 權限繞過，只下載有固定 SHA-256 的 ZIP 並安裝 `.app`。官方 Homebrew Cask 申請不屬於第一版，正式簽署後才重新評估。

## Risks / Trade-offs

- [EventKit full access 在系統層包含寫入能力] → 以不可變映射模型、無 save/remove API、程式碼檢查與測試證明產品唯讀，並在授權說明透明揭露。
- [純 menubar、可 resize、失焦關閉及釘選的組合可能有 SwiftUI 視窗限制] → 先完成 AppKit panel spike，建立失焦、Space、全螢幕及多螢幕驗收，再固定協調器設計。
- [Apple「行事曆」可能沒有穩定的單一事件 deep link] → 限制技術驗證時間；不可行或需 Automation 權限時，直接降級到事件日期。
- [ad-hoc Release 會觸發 Gatekeeper] → 只提供逐 App 手動核准文件；不自動移除 quarantine，並保留 Developer ID 升級路徑。
- [行事曆識別碼可能因帳號重建而改變] → 將未知新行事曆預設顯示，清除失效 ID，避免意外隱藏資料。
- [28 天 × 多事件可能造成 UI 或 EventKit 查詢延遲] → 只查目前範圍與所選行事曆、背景映射後於主執行緒一次更新，並以效能測試驗證合理的大型資料集。

## Migration Plan

1. 以固定 bundle identifier 建立 macOS App、測試 targets、Sandbox 與本機偏好結構。
2. 完成系統整合 spikes，確認 panel 行為、EventKit entitlement、登入時啟動及 Apple「行事曆」降級策略。
3. 完成能力實作與測試後產生 ad-hoc signed ZIP，於乾淨 macOS 15 Apple Silicon 環境人工驗收。
4. 手動建立 GitHub Release，計算 SHA-256，另行更新 `yuhaw0715/homebrew-tap` Cask。
5. 若 Release 有問題，從 GitHub Release 撤下受影響版本並將 Cask 回退至上一個已驗證版本；不變更使用者偏好格式。
6. 未來取得 Developer ID 後，以相同 archive 啟用正式簽署、hardened runtime、notarization 與 stapling，驗證後更新 Cask。

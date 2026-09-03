## Why

目前 Mac Menubar Calendar 介面採用寫死之深黑底色（`#1E1E21`）與傳統 1px 白色硬隔線，視覺較為生硬且缺少 macOS 原生系統材質之通透光澤。為呼應 macOS 26 次世代設計美學，在完全不異動任何畫面功能與既有排版的前提下，將介面視覺呈現升級為「方案 C-4（Soft Island 極窄微邊界浮島風格）」，提供超微 1.5px 間隔、4px 圓角卡片與 2px 極窄內留白，兼具懸浮晶片立體感與極致資訊顯示寬度。

## What Changes

- **100% 維持現有功能架構**：
  - 頂部導覽列維持不變：月份年份標題、`< 今天 >` 導覽膠囊、重新整理、圖釘、設定、退出按鈕。
  - 星期標頭（日～六）與連續 4 週 7×4 網格排版維持不變。
  - 儲存格內容維持不變：左上農曆/節氣、右上國曆（今日紅色圓圈）、全天行程色條、定時行程（色點+標題+時間）、溢位 `+N 個` 標籤。
  - 點擊單日跳轉之單日清單、事件詳情及設定頁面邏輯完全維持不變。
- **視覺呈現重構（方案 C-4）**：
  - **原生毛玻璃材質**：視窗底層以系統原生毛玻璃材質（`.ultraThinMaterial` / `behindWindow`）取代寫死之純黑背景，自然折射系統桌面桌布。
  - **極窄浮島微卡片（Soft Island）**：捨棄 1px 十字硬割線，改以 28 個獨立的懸浮晶片微卡片排列；卡片外間距設為 **1.5px**，卡片圓角為 **4px**。
  - **內部留白收斂（Tight Padding）**：儲存格內部邊距設為 **2px**，行程色標與標題可橫向延伸更寬，大幅減少文字被截斷的機率。
  - **光影與微互動升級**：卡片滑鼠懸停（Hover）時具備細膩的半透明聚光微光暈，今日標記採用現代立體飽和紅圈。

## Capabilities

### New Capabilities

無。

### Modified Capabilities

- `calendar-browsing`: 更新 28 天網格的視覺樣式規格，規範採用微間距圓角浮島微卡片與系統原生材質呈現。

## Impact

- 影響檔案：
  - `MacMenubarCalendar/Presentation/Panel/CalendarPanel.swift`（支援系統毛玻璃背景）
  - `MacMenubarCalendar/Presentation/Views/CalendarRootView.swift`（移除寫死背景，套用材質）
  - `MacMenubarCalendar/Presentation/Views/CalendarGridView.swift`（替換硬割線為 1.5px 浮島微卡片網格）
  - `MacMenubarCalendar/Presentation/Views/DayCellView.swift`（卡片背景、4px 圓角、2px 窄留白、Hover 微光暈）
  - `MacMenubarCalendar/Presentation/Views/HeaderControlsView.swift`（磨砂膠囊按鈕微光澤優化）
- 不破壞任何現有單元測試、不修改 EventKit 與 ViewModel 資料邏輯。

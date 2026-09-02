# Mac Menubar Calendar 🗓️

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%2015%2B%20%7C%20Apple%20Silicon-lightgrey.svg)](https://apple.com)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)

**Mac Menubar Calendar** 是一個專為 macOS 設計的原生、輕量級純 Menubar 行事曆檢視應用程式。透過 EventKit 安全存取已同步至 macOS 的 Apple「行事曆」（包含 Google 日曆等），嚴格維持唯讀與零遙測，保護您的隱私。

---

## ✨ 核心特色 (Features)

- **雙層緊湊 Menubar 圖示**：
  - 在頂部選單列顯示上下雙層的月份與日期（上層月份、下層兩位數日期）。
  - 自動依系統語言適配：中文環境顯示 `9月` / `02`，英文環境顯示 `SEP` / `02`。
  - 原生 Template 渲染，隨深淺色外觀與桌面桌布自動調整最佳對比度。
- **1:1 原生 Apple 深色月檢視**：
  - 一體化細格線連續 7 欄 × 4 列（28 天）**週對齊月曆網格**，自動依本週起始日為第一格排列。
  - 頂部年月標題一律以網格第 1 格所在的年月顯示（例如「2026年 8月」或「August 2026」）。
  - 完整支援**農曆與國曆雙日期標頭**（左上角顯示農曆初一、節氣或日期，右上角顯示國曆日期）。
  - **今日標記**：Apple 標誌性正紅色實心圓徽章（白字 `31`）＋「日」，精準落在當週對應星期欄位。
  - **全天行程膠囊**：滿版寬度圓角彩色橫幅（綠、藍、橘、棕等），白字加粗清晰排版。
  - **指定時間行程**：左側顏色點＋行程名稱，右側精確對齊等寬時間（如 `18:00`、`17:30`）。
  - **行程溢位展開**：超過可視空間時顯示「還有 N筆」，點擊可展開當日所有行程。
- **直覺導覽與操作**：
  - 支援「上一週」、「下一週」以 7 天整週平滑切換，並提供「今天」一鍵快速回正至當週起始日。
  - 支援視窗自由縮放與釘選（Pin）功能，在失焦時可保持顯示。
  - 單擊行程可查看詳細資訊（時間、地點、所屬行事曆），並可一鍵跳轉至 Apple「行事曆」App 繼續操作。
- **語言與偏好設定**：
  - 支援語言自動與手動切換（跟隨系統、繁體中文、English）。
  - 支援**一週第一天**偏好設定（跟隨系統、星期日、星期一），切換即時連動月曆網格與星期標頭排序。
  - 跟隨系統時，中文環境走繁體中文，非中文環境自動回退至英文。
- **便捷結束與快捷操作**：
  - 月曆視窗右上角提供紅色電源結束按鈕 (`⏻`)。
  - 選單列圖示支援**滑鼠右鍵選單**（開啟月曆、重新整理 `⌘R`、偏好設定 `⌘,`、結束 App `⌘Q`）。
- **多語系與無障礙支援**：
  - 介面完整提供繁體中文與英文支援。
  - 完整支援 VoiceOver 語意朗讀、全鍵盤操作導覽、動態字級與高對比模式。

---

## 🛡️ 安全與隱私承諾 (Privacy & Security)

- **嚴格唯讀**：應用程式架構採嚴格唯讀設計，不提供任何建立、修改或刪除行程的途徑。
- **純記憶體處理**：行程內容僅保留於記憶體中，絕不持久化儲存至本機資料庫或磁碟。
- **零遙測與資料收集**：無任何分析代碼、無崩潰回報上傳、不存取網路進行未授權傳輸。
- **最小權限 App Sandbox**：於 App Sandbox 內執行，僅申請讀取行事曆必要的 Sandbox Entitlement。
- **本機偏好保存**：所有使用者設定（選取的行事曆、視窗尺寸、外觀、語言、一週起始日、登入啟動等）皆只保存在本機 `UserDefaults`。

---

## 📦 安裝方式 (Installation)

### 1. 一鍵安裝 (推薦)

您可直接指定 Tap 儲存庫與 App 名稱進行單行一鍵安裝（無需分開執行 `brew tap`）：

```bash
brew install --cask yuhaw0715/tap/mac-menubar-calendar
```

> [!NOTE]
> **首次啟動說明 (Gatekeeper)**：
> 首次啟動若 macOS 顯示「無法驗證開發者」提示，請前往 macOS **「系統設定」>「隱私權與安全性」**，在安全性區塊下方點擊 **「仍要打開」** 即可正常啟動。

---

### 2. 更新至最新版

當有新版本發佈時，可透過以下指令升級：

```bash
brew update
brew upgrade --cask mac-menubar-calendar
```

---

### 3. 解除安裝 (Uninstall)

- **標準解除安裝**：
  ```bash
  brew uninstall --cask mac-menubar-calendar
  ```

- **完整乾淨移除（包含清除本機偏好設定檔與快取）**：
  ```bash
  brew uninstall --zap --cask mac-menubar-calendar
  ```

- **（選用）移除 Tap 儲存庫**：
  ```bash
  brew untap yuhaw0715/tap
  ```

---

## 🏗️ 程式與專案架構 (Architecture)

**Mac Menubar Calendar** 採用 Clean Architecture 與 MVVM 分層架構，並以協議（Protocol）為核心進行依賴注入與隔離，確保高可測試性與模組化：

```text
MacMenubarCalendar/
├── App/                       # 應用程式生命週期與選單列控制器
│   ├── AppDelegate.swift
│   ├── MacMenubarCalendarApp.swift
│   └── StatusItemController.swift
├── Core/                      # 核心業務邏輯、領域模型與服務協定
│   ├── Logic/                 # 純邏輯運算 (月曆網格、排版引擎、農曆轉換、圖示渲染)
│   │   ├── AppStrings.swift
│   │   ├── CalendarGridCalculator.swift
│   │   ├── DayLayoutEngine.swift
│   │   ├── EventFilterAndSorter.swift
│   │   ├── LunarDateHelper.swift
│   │   └── MenubarIconRenderer.swift
│   ├── Models/                # 不可變領域實體與列舉 (行程、授權、外觀、語言等)
│   │   ├── AppLanguage.swift
│   │   ├── AppearanceMode.swift
│   │   ├── AuthorizationStatus.swift
│   │   ├── CalendarEvent.swift
│   │   ├── CalendarSource.swift
│   │   ├── DayCellData.swift
│   │   └── FirstDayOfWeek.swift
│   ├── Protocols/             # 抽象服務介面 (供測試與 Mock 替換)
│   └── Services/              # 系統服務實作 (EventKit、UserDefaults、時鐘、通知等)
├── Presentation/              # 視圖模型與 SwiftUI / AppKit 介面層
│   ├── Panel/                 # 原生浮動無邊框面板控制器 (NSPanel)
│   ├── ViewModels/            # 視圖模型 (@Observable CalendarViewModel)
│   └── Views/                 # SwiftUI 視圖組件 (月曆網格、單日單元格、設定頁面等)
└── Resources/                 # 多語系資源檔 (.lproj)、Info.plist 與 Entitlements
```

---

## 🛠️ 開發、建置與測試 (Development & Testing)

### 系統需求

- **作業系統**：macOS 15.0+ (Sequoia) / macOS 26+
- **硬體架構**：Apple Silicon Mac（M1 / M2 / M3 / M4 系列晶片，arm64）
- **開發工具**：Xcode 16.0+ 或 Swift 6.0+

### 執行單元測試

```bash
swift test
```

### 本機編譯與運行

```bash
swift run
```

### 一鍵發布流程 (Release Workflow)

```bash
# 執行自動化 Release 編譯、簽署、打包 ZIP 並更新 Homebrew Cask
./scripts/build-release.sh

# 啟動最新建置的獨立 App
open "releases/Mac Menubar Calendar.app"
```

---

## 📄 授權 (License)

本專案採用 [MIT License](LICENSE) 授權。

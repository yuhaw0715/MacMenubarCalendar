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
- **專屬即時日曆 App 圖示（方案 3A 側邊紅標籤活頁日曆風）**：
  - 專為 macOS 打造的 Squircle 擬物化活頁日曆圖示，包含左側經典日曆紅索引書脊、撕頁虛線微投影、3 組金屬活頁環打孔眼與右側象牙白大日期數字。
  - **即時動態日期顯示**：App 運作期間自動在午夜換日、時區切換或休眠喚醒時，將圖示更新為當前月份、日期與星期幾。
  - **雙語系動態適配**：繁體中文模式呈現 `9月` / `週四`，英文模式呈現 `SEP` / `THU`。
  - 內建 16x16 至 1024x1024 完整尺寸的標準 `AppIcon.icns`，在 Finder、Launchpad、系統設定登入項目與授權清單中皆精緻呈現。
- **次世代 macOS 26 浮島微卡片月檢視（Soft Island 方案 C-4）**：
  - **極致原生毛玻璃（Liquid Glass）**：底層全面採用系統級 `.ultraThinMaterial` 毛玻璃材質與景深保護層，隨桌面桌布自然呈現通透的光學景深與折射。
  - **7 欄 × 4 列浮島微卡片（Soft Island Tiles）**：徹底捨棄傳統 1px 生硬切割線，改以 **1.5px 緊湊微間距**、**4px 圓角** 之獨立懸浮晶片卡片呈現，兼具立體層次與極高空間利用率。
  - **滿版緊湊內部留白（Tight 2px Padding）**：儲存格內部留白精算縮窄至 2px，大幅擴展全天行程橫幅與定時行程的橫向可用寬度，顯著減少標題截斷。
  - **晶透微外框與微光澤**：每張日期卡片附帶 0.5px 半透明晶透外框，滑鼠懸停（Hover）時具備細膩的動態聚光微光暈。
  - **今日立體標記**：Apple 標誌性正紅色實心漸層圓徽章（白字日數）＋「日」，精準落在當週對應星期欄位並附帶柔和微外發光。
  - **全天行程膠囊**：圓角彩色橫幅（綠、藍、橘、棕等），白字加粗清晰排版。
  - **指定時間行程**：左側顏色點＋行程名稱，右側精確對齊等寬時間（如 `18:00`、`17:30`）。
  - **行程溢位展開**：超過可視空間時顯示「還有 N 個」，點擊可展開當日所有行程。
  - 完整支援**農曆與國曆雙日期標頭**（左上角顯示農曆初一、節氣或日期，右上角顯示國曆日期）。
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

> [!TIP]
> **常駐位置與啟動說明**：
> - **純選單列常駐**：本 App 為極致輕量的 Menubar 工具，**不會出現在底部的 Dock（程式塢）**，安裝完成後會自動常駐於 **螢幕最頂部的選單列（右上角）**，顯示月份與日期圖示。
> - **啟動台 (Launchpad)**：Cask 安裝流程會自動解除隔離屬性並啟動 App，觸發系統將方案 3A 側邊紅標籤日曆圖示寫入「啟動台 (Launchpad)」。
> - 若首次手動啟動遇 macOS「無法驗證開發者」提示，請至 **「系統設定」>「隱私權與安全性」** 點擊 **「仍要打開」**。

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
│   │   ├── AppIconRenderer.swift
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
│   └── Services/              # 系統服務實作 (EventKit、UserDefaults、動態圖示控制器、通知監聽等)
│       ├── AppLoginItemManager.swift
│       ├── AppPreferencesStore.swift
│       ├── DynamicAppIconController.swift
│       ├── EventKitCalendarService.swift
│       ├── SystemCalendarOpener.swift
│       ├── SystemClock.swift
│       └── SystemNotificationWatcher.swift
├── Presentation/              # 視圖模型與 SwiftUI / AppKit 介面層
│   ├── Panel/                 # 原生浮動無邊框面板控制器 (NSPanel)
│   ├── ViewModels/            # 視圖模型 (@Observable CalendarViewModel)
│   └── Views/                 # SwiftUI 視圖組件 (Soft Island 浮島網格、單日微卡片、設定頁面等)
└── Resources/                 # 多語系資源檔 (.lproj)、AppIcon.icns、Info.plist 與 Entitlements
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

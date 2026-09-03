# AGENTS.md

## 專案概述

Mac Menubar Calendar 是一個原生 macOS menubar 行事曆檢視程式。它透過 EventKit 顯示已設定於 Apple「行事曆」中的事件，包括由 macOS 同步的 Google 日曆，但不直接登入第三方服務或自行同步。

## 文件與工作流程

- 已確認需求以 `docs/requirements.md` 為準。
- 主規格位於 `openspec/specs/`，歷史變更歸檔於 `openspec/changes/archive/`。
- proposal、design、specs、tasks 與其他專案文件使用繁體中文；API、程式碼及技術識別字可保留英文。
- 實作前必須先確認對應 OpenSpec 規格；若有新變更需先透過 OpenSpec 提案。
- 需求或外部行為改變時，先更新需求與 OpenSpec artifacts，不可只修改程式碼。
- 不得在未經使用者明確要求時建立 release、推送 repository 或修改外部 Homebrew tap。

## 平台與技術限制

- 最低支援 macOS 15 Sequoia。
- 只支援 Apple Silicon（arm64）。
- 使用 Swift、SwiftUI；只有 menubar、panel 或必要系統整合才使用 AppKit。
- 同時支援 Xcode 專案建置與 Swift Package Manager（SPM，`swift run` / `swift test`）。
- 一鍵打包發佈腳本為 `scripts/build-release.sh`（支援自動組裝 `.app`、簽署、產出 `releases/MacMenubarCalendar-v{version}.zip` 與更新 `homebrew-tap` Cask）。
- Bundle identifier 固定為 `com.yuhaw0715.MacMenubarCalendar`。
- App 為純 menubar App，不顯示 Dock 圖示。
- 啟用 App Sandbox。

## 安全與隱私

- 採最小權限原則，只加入讀取行事曆必要的 entitlement。
- EventKit 沒有唯讀授權；讀取事件需要 full access。程式架構仍必須維持唯讀，不得呼叫事件或行事曆的 save、remove、delete 或其他修改 API。
- UI 與 view model 不得直接持有可寫入的 EventKit 物件；先映射為不可變的應用程式模型。
- 不存取提醒事項、通知、聯絡人、相片、相機、麥克風、定位或非必要檔案。
- 不加入非必要網路能力，不直接連線 Google 或其他行事曆服務。
- 不持久化行程內容；事件只保留在記憶體。本機偏好不得包含事件標題、時間、地點或備註。
- 不加入分析、遙測、遠端錯誤回報或 App 內更新。
- 不得全域停用 Gatekeeper、自動移除 quarantine，或要求 root／管理員權限。
- 若必要功能似乎需要擴大 entitlement、關閉 Sandbox 或要求 Automation 權限，先停止並向使用者說明證據與替代方案。

## 架構與可測試性

- EventKit、時鐘／時區、偏好儲存、登入時啟動及開啟 Apple「行事曆」必須置於可替換介面後方。
- 自動測試使用假行事曆資料，不得依賴或讀取開發者的真實行事曆。
- 日期計算使用系統 Calendar 與半開區間，不以固定秒數推算天數。
- 所有日期與事件歸屬依 Mac 目前系統時區計算。
- 多語系字串統一透過 `AppStrings` 模組讀取，確保在 SPM `Bundle.module` 與 `.app` `Bundle.main` 環境下皆能正常解析並具備安全 Fallback。
- 選單列圖示透過 `MenubarIconRenderer` 繪製雙層（月份/日期）Template 影像，並根據 `AppLanguage` 與 `Locale` 自動切換中文（`9月`）與英文（`SEP`）。
- 應用程式圖示採用方案 3A（側邊紅標籤活頁日曆風），透過 `AppIconRenderer` 程式化繪製，並由 `DynamicAppIconController` 支援執行時即時換日、時區切換及中英文語系動態更新。
- 偏好儲存（`AppPreferencesStore`）支援行事曆選擇、拒絕行程、外觀、語言模式（`AppLanguage`）及一週起始日（`FirstDayOfWeek`）。
- 不引入 Core Data、SwiftData、iCloud、第三方同步 SDK 或遠端服務，除非需求與 OpenSpec 已明確更新並獲得確認。

## UI、在地化與輔助使用

- 介面視覺採用 macOS 26 次世代美學（方案 C-4 Soft Island 極窄微邊界浮島風格）：
  - 視窗底層以系統原生毛玻璃材質（`.ultraThinMaterial` / `NSVisualEffectView`）搭配半透明保護深色層，自然透出桌面背景景深，外觀自適應深淺色模式。
  - 7×4 網格移除傳統 1px 硬割線，改採 28 個獨立的懸浮微晶片卡片（Soft Island Tiles），卡片間距為 1.5px、圓角為 4px、內部留白緊湊化至 2px，最大化文字與行程色條之橫向展示寬度。
  - 卡片周圍具備 0.5px 半透明晶透微外框，Hover 支援平滑聚光光暈與輕柔陰影，今日日期採用現代高飽和立體微漸層圓標。
- 介面提供繁體中文與英文，支援「跟隨系統」、「繁體中文」與「English」切換，未支援語言回退英文；日期時間格式跟隨系統地區。
- 支援農曆日期計算與顯示（`LunarDateHelper`）。
- 支援 VoiceOver、完整鍵盤操作、清楚焦點順序、系統文字大小及提高對比。
- 行事曆、選取狀態與事件狀態不得只靠顏色表達。
- 使用 SwiftUI preview 或假資料驗證畫面，不得讓 preview 觸發真實 EventKit 授權。

## 品質要求

- 每項實作都應附上與風險相稱的單元測試、UI 測試或清楚的人工驗證紀錄。
- 至少涵蓋 28 天邊界、跨月／跨年／閏年、夏令時間、時區變更、跨日事件、全天排序、拒絕邀請及權限狀態。
- 修改後執行相關測試；發佈前執行完整測試與 Release build 驗證。

## 發佈限制

- App 原始碼與 GitHub Releases：`yuhaw0715/MacMenubarCalendar`。
- Homebrew tap：`yuhaw0715/homebrew-tap`；外部 tap 的修改需要使用者另行明確授權。
- 第一階段產物為包含 `Mac Menubar Calendar.app` 的 ad-hoc signed ZIP。
- 建置流程須保留未來切換 Developer ID、hardened runtime、notarization 與 stapling 的能力。
- 第一階段 release 與 Cask 均採授權操作；不得未經使用者明確要求自行建立 GitHub Release 或發佈 Cask。

## Repository 操作

- 保留使用者既有修改，不覆寫或還原無關檔案。
- 不使用破壞性 Git 指令。
- Git commit 訊息一律使用中文。
- 不得自動 commit 或 push；只有使用者在當次要求中明確授權後才可執行。
- 除非使用者明確要求，不建立 tag、branch、release 或 pull request。

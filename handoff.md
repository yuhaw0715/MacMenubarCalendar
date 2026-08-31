# Mac Menubar Calendar 交接文件

## 專案狀態

目前已完成需求探索、需求確認與 OpenSpec 規劃，尚未開始建立 Xcode 專案或實作 App。

- 產品名稱：Mac Menubar Calendar
- Bundle Identifier：`com.yuhaw0715.MacMenubarCalendar`
- 最低版本：macOS 15 Sequoia
- 支援架構：Apple Silicon（arm64）
- 技術方向：Swift、SwiftUI，必要的 menubar／panel 系統整合使用 AppKit
- App 形態：純 menubar App，不顯示 Dock 圖示
- 授權：MIT License（尚待實作階段加入正式 LICENSE 檔案）

## 主要文件

- `AGENTS.md`：專案開發、安全、Git 與 OpenSpec 規則
- `docs/requirements.md`：已由使用者確認的繁體中文需求文件
- `openspec/changes/build-mac-menubar-calendar/proposal.md`：已完成的變更提案
- `openspec/changes/build-mac-menubar-calendar/design.md`：技術設計與風險處理
- `openspec/changes/build-mac-menubar-calendar/tasks.md`：可追蹤的實作清單
- `openspec/changes/build-mac-menubar-calendar/specs/`：四份能力規格

OpenSpec change 名稱為 `build-mac-menubar-calendar`，已通過：

```sh
openspec validate build-mac-menubar-calendar --strict
```

## 已確認的產品範圍

- Menubar 顯示今天日期。
- 點擊後顯示從今天起的固定 28 天，以 7 欄 × 4 列排列。
- 可每次前後移動 7 天，並可回到今天。
- 日期格顯示行程標題與所屬行事曆顏色圓點；過多時顯示「還有 N 筆」。
- 點擊日期顯示完整單日清單，點擊事件顯示標題、起迄時間、行事曆與地點。
- 事件可交由 Apple「行事曆」繼續操作；無法定位單一事件時降級至事件日期。
- 只透過 EventKit 讀取 macOS 已設定的行事曆，包括已同步的 Google 日曆。
- 預設顯示所有行事曆，可個別切換並在本機記住選擇。
- 預設隱藏已拒絕邀請，可由設定顯示。
- 視窗可調整大小、記住尺寸並可釘選。
- 提供跟隨系統、淺色與深色外觀。
- 提供繁體中文與英文，並支援 VoiceOver、鍵盤操作、文字大小與提高對比。
- 登入時啟動預設關閉，使用 `SMAppService.mainApp`。
- 第一階段透過 GitHub Release ZIP 與 `yuhaw0715/homebrew-tap` 手動發佈 Cask。

## 安全與隱私界線

- 啟用 App Sandbox，只加入行事曆必要 entitlement。
- EventKit 讀取事件必須取得 full access，但產品層必須維持唯讀，不能建立、修改或刪除事件。
- EventKit 物件須先映射成不可變模型；View 與 view model 不得取得寫入 API。
- 不讀取提醒事項，不直接登入 Google，不自行同步。
- 不持久化行程內容，不使用 iCloud 保存設定。
- 不加入分析、遙測、遠端錯誤回報、額外通知或 App 內更新。
- 不申請非必要網路、檔案、相機、麥克風、定位或 Automation 權限。
- 不得全域停用 Gatekeeper或自動移除 quarantine。

## 發佈安排

- App repository：`https://github.com/yuhaw0715/MacMenubarCalendar`
- Homebrew tap：`https://github.com/yuhaw0715/homebrew-tap`
- Cask token：`mac-menubar-calendar`
- 安裝指令：`brew install --cask yuhaw0715/tap/mac-menubar-calendar`
- 第一階段使用 ad-hoc code signing；使用者第一次啟動時可能需要在系統設定逐 App 核准。
- 發佈流程須預留 Developer ID Application、hardened runtime、notarization 與 stapling。
- 不得自動建立 GitHub Release 或修改外部 tap，除非使用者在當次要求中明確授權。

## 下一步

下一個工作階段若要開始實作，使用者必須明確要求套用 OpenSpec change：

```text
請套用 build-mac-menubar-calendar change
```

之後使用 `openspec-apply-change` 工作流程，依 `tasks.md` 順序進行。優先完成：

1. macOS App、測試 targets、Sandbox 與 bundle identifier 骨架。
2. AppKit panel、EventKit entitlement、`SMAppService.mainApp` 及 Apple「行事曆」定位的技術驗證。
3. 可注入的 EventKit、時鐘／時區、偏好與系統整合介面。

實作期間完成一項任務後，應更新 `tasks.md` checkbox，執行相稱測試，並再次執行 OpenSpec 嚴格驗證。

## Git 規則

- Commit 訊息一律使用中文。
- 不得自動 commit 或 push；必須有使用者當次明確授權。
- 保留使用者既有變更，不使用破壞性 Git 指令。
- 本文件建立時，使用者已明確授權本次建立 commit 並 push。

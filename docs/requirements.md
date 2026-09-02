# Mac Menubar Calendar 需求文件

## 1. 文件狀態

- 狀態：待使用者確認
- 文件語言：繁體中文
- 產品名稱：Mac Menubar Calendar
- Bundle Identifier：`com.yuhaw0715.MacMenubarCalendar`
- 本文件確認前，不建立 OpenSpec proposal，也不進入實作。
- 本文件確認後，OpenSpec proposal、design、specs 與 tasks 均以繁體中文撰寫；API、技術識別字與程式碼可保留英文。

## 2. 產品目標

建立一個輕量、原生、純 menubar 的 macOS 行事曆檢視程式。程式透過 macOS EventKit 顯示已設定於 Apple「行事曆」中的行事曆，包括由 macOS 同步的 Google 日曆等，不直接登入第三方服務，也不自行進行網路同步。

核心使用情境是：使用者點擊 menubar 上的今日日期，快速查看從指定起始日開始、連續 28 天的行程，並可查看單一行程的基本詳情。

## 3. 支援平台與技術

- 最低版本：macOS 15 Sequoia。
- 處理器：只支援 Apple Silicon（M1 及後續）。
- 技術：原生 Swift + SwiftUI；只有 SwiftUI 不足以處理 menubar、浮動視窗或系統整合時才使用 AppKit。
- App 形態：純 menubar App，不顯示 Dock 圖示。
- 啟用 App Sandbox；只開放完成需求所必須的 entitlement。
- Bundle Identifier 固定為 `com.yuhaw0715.MacMenubarCalendar`，避免未來簽署後造成偏好與權限識別變動。

## 4. Menubar 與主視窗

### 4.1 Menubar 項目

- Menubar 顯示今天的日期數字，例如 `31`。
- 日期跨日或系統時區改變時，menubar 日期必須更新。
- 點擊 menubar 日期開啟月曆視窗。

### 4.2 視窗行為

- 預設點擊視窗外部即關閉。
- 提供釘選功能；釘選後即使失去焦點仍保持開啟。
- 視窗提供合理的預設大小，允許使用者縮放並記住尺寸。
- 即使視窗被釘選，App 仍不顯示 Dock 圖示。
- 每次關閉後重新打開月曆視窗，日期範圍回到包含今天之該週起始日起算連續 28 天，不保留上次瀏覽位置。

## 5. 28 天月曆

### 5.1 日期範圍與版面

- 預設顯示包含當前基準日之本週起始日起算連續 28 天。
- 使用 7 欄 × 4 列排列，每列為連續 7 天（一整週）。
- 星期欄位標頭依照有效的一週起始日排序；「今天」紅色圓形徽章落在第一列對應欄位；頂部年月標題依第一格所在年月顯示。
- 提供上一週、下一週控制，每次將整個 28 天範圍前移或後移 7 天（一整週）。
- 提供「回到今天」，將範圍重設為包含今天的該週起始日起算 28 天。

### 5.2 日期格內容

- 每個日期格直接顯示當天的行程標題。
- 標題旁顯示所屬行事曆的顏色圓點。
- 輔助使用資訊不得只靠顏色傳達，須同時提供所屬行事曆的文字標籤。
- 同一天先顯示全天行程，其餘依開始時間排序。
- 跨日行程在涵蓋的每一天都顯示標題。
- 每格可顯示的行程筆數依視窗尺寸及系統文字大小動態計算。
- 無法全部顯示時，顯示前幾筆及「還有 N 筆」。
- 點擊日期或「還有 N 筆」後，顯示該日完整行程清單。
- 預設不顯示已拒絕的會議邀請。
- 設定中提供「顯示已拒絕行程」開關；開啟後以淡化樣式呈現。

### 5.3 時區

- 日期與時間一律依 Mac 目前系統時區顯示。
- 系統時區變更後，重新計算日期邊界並重新載入事件。

## 6. 行程詳情與 Apple 行事曆整合

- 點擊行程後，先在本 App 中顯示詳情，不立即切換 App。
- 詳情只顯示：
  - 標題
  - 開始時間
  - 結束時間
  - 所屬行事曆
  - 地點
- 不顯示備註、附件或視訊會議／網址。
- 詳情提供「在行事曆中開啟」按鈕。
- 優先嘗試在 Apple「行事曆」中定位指定事件。
- 若 macOS 公開 API 無法精準定位，降級為開啟 Apple「行事曆」並切換至該事件日期。
- 精準定位能力列為實作前技術驗證項目，不在需求階段保證一定可行。
- 本 App 不建立、修改或刪除任何行程。

## 7. 行事曆來源與選擇

- 只透過 EventKit 讀取已設定在 Apple「行事曆」中的事件。
- 支援 macOS 已同步的本機、iCloud、Google 等行事曆來源。
- 不提供 Google 或其他第三方帳號登入。
- 不自行連網同步行事曆。
- 預設選取並顯示所有可用行事曆。
- 設定中可勾選或取消各行事曆，並記住選擇。
- 行事曆清單變更時，須妥善處理已刪除、重新建立或識別碼改變的行事曆；新出現的行事曆預設顯示。
- 不讀取或整合 Apple「提醒事項」。
- 不提供行程搜尋。

## 8. 資料更新

- 每次打開月曆視窗時重新讀取目前範圍的事件。
- 視窗開啟期間監聽 EventKit 資料變更通知並重新整理。
- 提供手動重新整理按鈕。
- 不自行設定固定輪詢計時器。
- 沿用 Apple「行事曆」既有通知；本 App 不另行發送行程通知，也不申請通知權限。

## 9. 權限、Sandbox 與隱私

### 9.1 最小權限原則

- 啟用 App Sandbox。
- Sandboxed macOS App 僅加入 EventKit 所需的 `com.apple.security.personal-information.calendars` entitlement。
- 不申請提醒事項、通知、聯絡人、相片、相機、麥克風、定位、檔案、藍牙或其他非必要權限。
- 第一版不具備 App 內更新與第三方同步，因此不應開放非必要的網路 client entitlement。
- 若技術驗證發現 Sandbox 與必要功能存在無法避免的衝突，必須提出具體證據並重新取得使用者確認，不得自行關閉 Sandbox 或擴大權限。

### 9.2 EventKit 權限限制

Apple 的 EventKit 公開 API 不提供「唯讀」授權層級。App 若要讀取事件，系統層級必須呼叫 `requestFullAccessToEvents`，並提供 `NSCalendarsFullAccessUsageDescription`；該系統權限在技術上也包含寫入能力。

因此，本產品的最小權限策略為：

- 只申請讀取事件所必須的 EventKit full access。
- 應用程式架構中不提供任何寫入、儲存或刪除 EventKit 資料的程式路徑。
- 權限說明必須清楚告知：系統要求完整存取才能讀取，但本 App 僅用於顯示，不會修改行事曆。
- 不申請 Reminders access。

### 9.3 拒絕或受限制狀態

- 初次需要讀取資料且狀態為未決定時，才提出行事曆授權要求。
- 若使用者拒絕或系統限制存取，顯示用途說明與「開啟系統設定」按鈕。
- 不在每次開啟視窗時反覆彈出授權要求。
- 沒有權限時仍應能開啟設定、查看隱私說明與結束 App。

### 9.4 資料保存與遙測

- 不建立行程資料庫，不將行程內容持久化至磁碟。
- 只在記憶體中保留目前顯示所需事件，重新整理時替換。
- 只在本機保存偏好設定，包括：選取的行事曆、是否顯示已拒絕行程、外觀、語言模式、一週起始日、視窗尺寸、釘選狀態及登入時啟動設定。
- 不使用 iCloud 同步偏好設定。
- 不蒐集使用分析、不整合遠端崩潰回報、不傳送遙測資料。

## 10. 設定

設定入口由 menubar 視窗提供，至少包含：

- 顯示／隱藏各行事曆。
- 顯示已拒絕行程，預設關閉。
- 登入時啟動，預設關閉。
- 外觀：跟隨系統、淺色、深色；預設跟隨系統。
- 語言：跟隨系統、繁體中文、English；預設跟隨系統。
- 一週第一天：跟隨系統、星期日、星期一；預設跟隨系統。
- 必要的權限狀態說明及前往系統設定入口。

登入時啟動應使用 macOS 的 `SMAppService.mainApp` 等公開 Service Management API，不安裝 LaunchDaemon，不要求管理員或 root 權限。

## 11. 在地化與輔助使用

### 11.1 在地化

- 第一版提供繁體中文與英文。
- 介面語言跟隨 macOS 系統語言；其他語言回退英文。
- 日期、星期及時間格式跟隨系統地區設定。

### 11.2 外觀

- 預設跟隨 macOS 淺色／深色模式。
- 使用者可手動指定淺色或深色，並記住選擇。
- 使用系統語意色彩，確保不同外觀下的可讀性。

### 11.3 輔助使用

- 支援 VoiceOver。
- 支援完整鍵盤操作與清楚的焦點順序。
- 支援系統文字大小設定；放大文字時不得遮蔽必要操作。
- 支援提高對比。
- 日期、行程、「還有 N 筆」、導覽、釘選與設定控制均須具備有意義的 accessibility label／value／hint。
- 不得只使用顏色表示行事曆、選取狀態或事件狀態。

## 12. 安裝、簽署與發佈

### 12.1 Repository

- App 原始碼與 GitHub Releases：`https://github.com/yuhaw0715/MacMenubarCalendar`
- Homebrew tap：`https://github.com/yuhaw0715/homebrew-tap`
- 授權：MIT License。

### 12.2 Release 成品

- GitHub Release 提供 ZIP。
- ZIP 內含 `Mac Menubar Calendar.app`。
- 第一階段使用 ad-hoc code signing，不使用 Developer ID 與 notarization。
- 第一次啟動可能被 Gatekeeper 阻擋；文件引導使用者至「系統設定 → 隱私權與安全性 → 仍要打開」逐 App 核准。
- 不得要求全域停用 Gatekeeper。
- Cask 或其他腳本不得自動移除 quarantine、修改 Gatekeeper 設定或要求 root 權限。

### 12.3 未來正式簽署

建置及發佈流程須將簽署身份與 notarization 設定參數化，以便未來取得 Apple Developer Program 會員資格後切換至 Developer ID Application 簽署、hardened runtime、notarization 與 stapling，而不需改變 App 架構、bundle identifier 或使用者偏好儲存位置。

### 12.4 Homebrew

- Cask token：`mac-menubar-calendar`。
- 預期安裝指令：`brew install --cask yuhaw0715/tap/mac-menubar-calendar`。
- 第一版由維護者手動建立 GitHub Release。
- 維護者手動更新 `homebrew-tap` 中 Cask 的版本、下載網址與 SHA-256。
- 第一版只透過 `brew upgrade --cask` 更新；App 不檢查、下載或安裝新版。
- 未來取得 Developer ID 後再評估 App 內更新。
- 需要繞過 Gatekeeper 的版本不符合官方 Homebrew Cask 收錄條件；申請收錄官方 Cask 前，必須完成 Developer ID 簽署及 notarization，並重新核對當時規則。

## 13. 測試與驗收

### 13.1 可測試架構

- EventKit 存取須透過可替換的抽象層。
- 自動測試使用假行事曆資料，不依賴或讀取開發者的真實行事曆。
- 時鐘、系統時區與「今天」須可注入，以穩定測試日期邊界。
- 偏好儲存須可替換，避免測試污染正式設定。

### 13.2 單元測試至少涵蓋

- 固定 28 天範圍及 7 × 4 排列。
- 上一週、下一週與回到今天。
- 跨月、跨年、閏年、夏令時間與系統時區變更。
- 全天行程優先及一般行程時間排序。
- 跨日與重複行程在各日的呈現。
- 已拒絕行程的預設過濾與設定切換。
- 行事曆選擇的保存、新增及移除。
- 「還有 N 筆」計算。
- EventKit 權限的未決定、允許、拒絕及受限制狀態。
- 繁體中文、英文及其他語言回退。

### 13.3 UI 測試至少涵蓋

- Menubar 開啟與關閉月曆。
- 釘選及取消釘選。
- 日期範圍導覽及回到今天。
- 展開單日完整清單與行程詳情。
- 設定行事曆篩選、拒絕行程、外觀及登入時啟動。
- 權限被拒後的說明與系統設定入口。
- VoiceOver 標籤、鍵盤焦點順序、文字放大及提高對比的關鍵流程。

### 13.4 人工驗收至少涵蓋

- 真實 EventKit 與 Apple「行事曆」資料一致。
- 已由 macOS 同步的 Google 日曆可正常顯示。
- Apple「行事曆」資料變更後，開啟期間可自動刷新，也可手動刷新。
- 登入時啟動開關預設關閉，啟用及停用皆不要求管理員權限。
- Homebrew Cask 可在乾淨的 Apple Silicon macOS 15 環境安裝、升級及移除。
- ad-hoc signed 版本的 Gatekeeper 手動核准說明正確，且安裝流程未修改全域安全設定。
- 未來正式簽署所需參數已有清楚的建置與發佈介面。

## 14. 第一版明確不做

- 建立、編輯或刪除行程。
- Apple「提醒事項」整合。
- Google 或其他第三方帳號登入與直接同步。
- 行程搜尋。
- App 自有行程通知。
- iCloud 設定同步。
- 分析、遙測或遠端崩潰回報。
- App 內更新。
- Intel Mac 或 Universal Binary。
- App Store 發佈。
- 未經使用者操作繞過或全域停用 Gatekeeper。

## 15. OpenSpec proposal 前待確認／技術驗證

以下項目不阻止需求文件確認，但必須在 design 或實作任務中明確處理：

1. 驗證在 macOS 15 上從本 App 精準定位 Apple「行事曆」單一事件的公開 API；若不可行，採開啟對應日期的降級行為。
2. 驗證 App Sandbox、EventKit calendar entitlement、純 menubar activation policy、可調整且可釘選的視窗與 `SMAppService.mainApp` 能共同運作。
3. 驗證 ad-hoc signed ZIP 經 GitHub Release 與 Homebrew Cask 下載後，在目前 macOS／Homebrew 版本上的 Gatekeeper 使用者核准流程；不得以自動移除 quarantine 作為解法。
4. 在申請官方 Homebrew Cask 或啟用 Developer ID 發佈前，重新核對 Apple 與 Homebrew 的最新規則。

## 16. 需求確認門檻

只有在使用者明確表示本文件內容已確認後，才可建立 OpenSpec change 並產生中文 proposal。確認需求文件不等同於授權實作；proposal 仍須再由使用者確認，之後才可進入實作階段。

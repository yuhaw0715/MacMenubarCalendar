## 1. 專案骨架與安全基線

- [ ] 1.1 建立 macOS 15、Apple Silicon 的 Swift／SwiftUI App、單元測試與 UI 測試 targets，設定產品名稱及 bundle identifier
- [ ] 1.2 設定純 menubar activation policy、App Sandbox、calendar entitlement 與中英文行事曆用途說明
- [ ] 1.3 加入 MIT License、基礎 README、無遙測與唯讀行事曆的隱私說明
- [ ] 1.4 建立可注入的行事曆、時鐘／時區、偏好、登入項目及 Apple「行事曆」開啟介面與假實作

## 2. 系統整合技術驗證

- [ ] 2.1 驗證可調整尺寸、失焦關閉、可釘選且無 Dock 圖示的 AppKit panel，記錄多螢幕、Space 與全螢幕結果
- [ ] 2.2 驗證 macOS 15 Sandbox 下 EventKit full access 授權、calendar entitlement 及事件變更通知
- [ ] 2.3 驗證 `SMAppService.mainApp` 啟用、停用、拒絕與狀態同步，不使用 helper 或管理員權限
- [ ] 2.4 驗證 Apple「行事曆」單一事件或日期定位方式；若精準定位需額外 Automation 權限，固定採日期降級方案

## 3. 日期與事件核心

- [ ] 3.1 實作依目前時區計算的半開 28 天範圍、前後 7 天導覽、回到今天及重新開啟重設
- [ ] 3.2 實作不可變的行事曆與事件摘要模型，以及 EventKit 唯讀 adapter
- [ ] 3.3 實作全天優先、開始時間排序、跨日分派、重複事件及拒絕邀請過濾
- [ ] 3.4 實作行事曆清單同步、預設全選、本機選擇保存、新增預設選取及失效識別碼清除
- [ ] 3.5 實作開啟時讀取、EventKit 變更刷新、手動刷新及只在記憶體替換事件資料
- [ ] 3.6 實作跨日與系統時區變更監聽，更新 menubar 日期、日期範圍及事件映射

## 4. Menubar 月曆介面

- [ ] 4.1 實作顯示今日日期的 menubar status item、開關視窗、設定入口及結束 App
- [ ] 4.2 實作 7 欄 × 4 列的 28 天網格與上一週、下一週、回到今天控制
- [ ] 4.3 實作日期格事件標題、行事曆顏色標記、動態可見筆數及「還有 N 筆」
- [ ] 4.4 實作完整單日事件清單與限定欄位的事件詳情
- [ ] 4.5 實作「在行事曆中開啟」及已驗證的日期降級行為
- [ ] 4.6 實作 panel resize、尺寸保存、失焦關閉、釘選與取消釘選
- [ ] 4.7 實作權限未決定、允許、拒絕與受限制的畫面及系統設定入口

## 5. 設定、在地化與輔助使用

- [ ] 5.1 實作行事曆顯示選擇與「顯示已拒絕行程」設定，確認預設值符合規格
- [ ] 5.2 實作登入時啟動開關、系統核准狀態及錯誤回饋，預設保持關閉
- [ ] 5.3 實作跟隨系統／淺色／深色外觀及本機保存
- [ ] 5.4 完成繁體中文與英文在地化、其他語言英文回退及地區日期時間格式
- [ ] 5.5 為日期、事件、溢位、導覽、釘選及設定加入 VoiceOver 語意與完整鍵盤焦點順序
- [ ] 5.6 驗證系統文字放大與提高對比，確保必要操作可達且資訊不只靠顏色

## 6. 自動測試與品質驗證

- [ ] 6.1 為 28 天邊界、前後導覽、跨月、跨年、閏年、夏令時間及時區變更加上單元測試
- [ ] 6.2 為全天排序、跨日、重複事件、拒絕過濾、行事曆選擇及「還有 N 筆」加上單元測試
- [ ] 6.3 為 EventKit 授權狀態、刷新流程、唯讀映射及不持久化事件內容加上測試
- [ ] 6.4 為 menubar 視窗、釘選、日期導覽、單日清單、事件詳情及設定加入 UI 測試
- [ ] 6.5 以繁體中文、英文、英文回退、VoiceOver、鍵盤、文字放大及提高對比完成自動或人工輔助使用驗收
- [ ] 6.6 使用大型假資料集驗證 28 天查詢、事件映射與網格更新效能

## 7. 發佈與 Homebrew 驗收

- [ ] 7.1 建立分離 archive、簽署、驗證、ZIP 打包及 SHA-256 的 Release 流程，簽署身份可切換 ad-hoc 或 Developer ID
- [ ] 7.2 驗證 Release App 的 arm64 架構、macOS 15 最低版本、bundle identifier、Sandbox entitlement 與 ad-hoc signature
- [ ] 7.3 建立使用者安裝、逐 App Gatekeeper 核准、Homebrew 安裝／升級／移除及疑難排解文件，不提供安全機制繞過指令
- [ ] 7.4 準備 `mac-menubar-calendar` Cask 範本，使用 GitHub Release ZIP 與固定 SHA-256，不加入 quarantine 或 Gatekeeper 修改腳本
- [ ] 7.5 在乾淨的 Apple Silicon macOS 15 環境人工驗收真實 EventKit、已同步 Google 日曆、登入時啟動、ZIP 與 Homebrew Cask
- [ ] 7.6 記錄手動 GitHub Release 與 `yuhaw0715/homebrew-tap` 更新步驟，以及未來 Developer ID、hardened runtime、notarization 與 stapling 操作介面

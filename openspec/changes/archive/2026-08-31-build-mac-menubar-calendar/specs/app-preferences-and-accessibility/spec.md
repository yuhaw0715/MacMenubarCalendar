## Purpose

定義純 menubar 視窗、偏好保存、登入時啟動、語言外觀及輔助使用行為，使應用程式在不增加非必要權限的前提下可長期使用。

## ADDED Requirements

### Requirement: 純 menubar 操作
系統 SHALL 只在 menubar 常駐而不顯示 Dock 圖示，並從 menubar 提供月曆、設定及結束 App 的入口。

#### Scenario: App 啟動
- **WHEN** App 完成啟動
- **THEN** menubar 出現日期項目且 Dock 不出現 App 圖示

### Requirement: 可調整與釘選的視窗
系統 SHALL 提供可調整大小的預設視窗並記住尺寸；未釘選時點擊外部 SHALL 關閉視窗，釘選後失去焦點 SHALL 保持開啟。

#### Scenario: 調整視窗尺寸
- **WHEN** 使用者調整月曆視窗大小後再次開啟
- **THEN** 系統恢復最近保存的有效尺寸

#### Scenario: 釘選視窗
- **WHEN** 使用者啟用釘選並切換至其他 App
- **THEN** 月曆視窗保持可見且 App 仍無 Dock 圖示

### Requirement: 本機保存偏好
系統 SHALL 只在本機保存行事曆選擇、拒絕事件顯示、外觀、視窗尺寸、釘選及登入時啟動狀態，MUST NOT 使用 iCloud 同步。

#### Scenario: App 重新啟動
- **WHEN** 使用者修改偏好後重新啟動 App
- **THEN** 系統恢復已保存偏好，但日期範圍仍回到今天

### Requirement: 可選的登入時啟動
系統 SHALL 提供預設關閉的登入時啟動開關，啟用或停用 MUST NOT 要求管理員或 root 權限。

#### Scenario: 首次啟動
- **WHEN** 使用者第一次啟動 App
- **THEN** 登入時啟動為關閉

#### Scenario: 啟用登入時啟動
- **WHEN** 使用者開啟登入時啟動並完成系統要求的使用者核准
- **THEN** App 在該使用者下次登入時自動啟動

### Requirement: 提供在地化介面
系統 SHALL 提供繁體中文與英文，依系統語言選擇；未支援語言 SHALL 回退英文，日期與時間格式 SHALL 跟隨系統地區設定。

#### Scenario: 未支援的系統語言
- **WHEN** macOS 使用非繁體中文且非英文的語言
- **THEN** App 介面使用英文並保留使用者的地區日期時間格式

### Requirement: 提供外觀選擇
系統 SHALL 提供跟隨系統、淺色及深色三種外觀，預設跟隨系統並保存使用者選擇。

#### Scenario: 手動選擇深色
- **WHEN** 使用者將外觀指定為深色
- **THEN** App 使用深色語意色彩且不受後續系統外觀切換影響

### Requirement: 支援輔助使用
系統 MUST 支援 VoiceOver、完整鍵盤操作、清楚焦點順序、系統文字大小及提高對比；日期、事件、溢位、導覽、釘選及設定 MUST 具有有意義的輔助標籤，資訊不得只靠顏色傳達。

#### Scenario: VoiceOver 瀏覽事件
- **WHEN** VoiceOver 使用者聚焦事件摘要
- **THEN** 系統朗讀事件標題、所屬行事曆及必要狀態，而非只描述顏色

#### Scenario: 放大系統文字
- **WHEN** 使用者放大系統文字
- **THEN** 必要操作仍可到達，日期格改以較少摘要及正確的「還有 N 筆」適應空間

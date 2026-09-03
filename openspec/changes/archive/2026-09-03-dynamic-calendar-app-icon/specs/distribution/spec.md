## ADDED Requirements

### Requirement: App Bundle 包含專屬程式圖示與發佈簽署
發佈成品 `Mac Menubar Calendar.app` SHALL 包含有效的 `AppIcon.icns` 靜態圖示檔案於 `Contents/Resources/`，且 `Info.plist` MUST 宣告 `CFBundleIconFile` 指向 `AppIcon`。發佈打包腳本 `scripts/build-release.sh` SHALL 在組裝 App Bundle 時驗證圖示檔案存在並將其包含於程式碼簽署範圍中。

#### Scenario: 檢查 Release App Bundle 圖示配置
- **WHEN** 發佈腳本組裝並簽署 `Mac Menubar Calendar.app`
- **THEN** `Contents/Resources/AppIcon.icns` 存在，`Info.plist` 包含正確的 `CFBundleIconFile` 鍵值，且 codesign 驗證成功通過

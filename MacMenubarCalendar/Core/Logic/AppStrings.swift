import Foundation
import SwiftUI
import os

public enum AppStrings {
    private static let _currentLanguage = OSAllocatedUnfairLock(initialState: AppLanguage.system)

    public static var currentLanguage: AppLanguage {
        get { _currentLanguage.withLock { $0 } }
        set { _currentLanguage.withLock { $0 = newValue } }
    }

    public static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle.main
        #endif
    }

    public static func localized(_ key: String, language: AppLanguage? = nil) -> String {
        let lang = language ?? currentLanguage
        let isZh = lang.isChinese()
        let lprojName = isZh ? "zh-Hant" : "en"

        if let path = bundle.path(forResource: lprojName, ofType: "lproj"),
           let lprojBundle = Bundle(path: path) {
            let val = lprojBundle.localizedString(forKey: key, value: nil, table: nil)
            if val != key {
                return val
            }
        } else {
            let val = bundle.localizedString(forKey: key, value: nil, table: nil)
            if val != key {
                return val
            }
        }

        // Comprehensive Fallback Dictionary
        if isZh {
            switch key {
            case "header.nav.today": return "今天"
            case "header.nav.prev_week": return "上一週"
            case "header.nav.next_week": return "下一週"
            case "header.action.refresh": return "重新整理"
            case "header.action.pin": return "釘選視窗"
            case "header.action.unpin": return "取消釘選"
            case "header.action.settings": return "設定"
            case "action.quit": return "結束 App"
            case "action.open_in_calendar": return "在「行事曆」中開啟"
            case "action.close": return "關閉"
            case "action.back": return "返回"
            case "action.done": return "完成"
            case "event.untitled": return "無標題行程"
            case "cell.more_events": return "還有 %d 筆"
            case "day_detail.no_events": return "當日沒有行程"
            case "event.all_day": return "全天"
            case "event.status.declined": return "已拒送"
            case "event.detail.start": return "開始"
            case "event.detail.end": return "結束"
            case "event.location": return "地點"
            case "settings.title": return "偏好設定"
            case "settings.calendars.header": return "顯示行事曆"
            case "settings.calendars.none_available": return "沒有可用的行事曆"
            case "settings.general.header": return "一般設定"
            case "settings.show_declined_events": return "顯示已拒絕的行程"
            case "settings.launch_at_login": return "登入時啟動"
            case "settings.appearance.title": return "外觀"
            case "settings.appearance.system": return "跟隨系統"
            case "settings.appearance.light": return "淺色"
            case "settings.appearance.dark": return "深色"
            case "settings.language.title": return "語言"
            case "settings.language.system": return "跟隨系統"
            case "settings.language.zh_hant": return "繁體中文"
            case "settings.language.en": return "English"
            case "settings.about.title": return "關於與隱私"
            case "settings.about.privacy_note": return "本 App 為唯讀檢視器，不收集資料，所有偏好僅保存於本機。"
            case "settings.open_privacy_settings": return "開啟系統隱私設定…"
            case "permission.welcome.title": return "歡迎使用 Mac Menubar Calendar"
            case "permission.welcome.description": return "Mac Menubar Calendar 需要行事曆存取權限以在選單列中顯示您的近期行程。本 App 嚴格維持唯讀，絕不建立、修改或刪除任何資料。"
            case "permission.grant_button": return "授予行事曆權限"
            case "permission.denied.title": return "需要行事曆權限"
            case "permission.denied.description": return "行事曆存取權限已遭拒絕或受系統限制。請前往 macOS「系統設定」>「隱私權與安全性」>「行事曆」開啟權限。"
            case "permission.open_settings_button": return "開啟系統設定"
            default: return key
            }
        } else {
            switch key {
            case "header.nav.today": return "Today"
            case "header.nav.prev_week": return "Previous week"
            case "header.nav.next_week": return "Next week"
            case "header.action.refresh": return "Refresh"
            case "header.action.pin": return "Pin window"
            case "header.action.unpin": return "Unpin window"
            case "header.action.settings": return "Settings"
            case "action.quit": return "Quit App"
            case "action.open_in_calendar": return "Open in Calendar"
            case "action.close": return "Close"
            case "action.back": return "Back"
            case "action.done": return "Done"
            case "event.untitled": return "Untitled Event"
            case "cell.more_events": return "%d more"
            case "day_detail.no_events": return "No events for this day"
            case "event.all_day": return "All-day"
            case "event.status.declined": return "Declined"
            case "event.detail.start": return "Start"
            case "event.detail.end": return "End"
            case "event.location": return "Location"
            case "settings.title": return "Preferences"
            case "settings.calendars.header": return "Calendars"
            case "settings.calendars.none_available": return "No calendars available"
            case "settings.general.header": return "General"
            case "settings.show_declined_events": return "Show declined events"
            case "settings.launch_at_login": return "Launch at login"
            case "settings.appearance.title": return "Appearance"
            case "settings.appearance.system": return "System"
            case "settings.appearance.light": return "Light"
            case "settings.appearance.dark": return "Dark"
            case "settings.language.title": return "Language"
            case "settings.language.system": return "System"
            case "settings.language.zh_hant": return "繁體中文"
            case "settings.language.en": return "English"
            case "settings.about.title": return "About & Privacy"
            case "settings.about.privacy_note": return "Strictly read-only calendar viewer with zero telemetry. All preferences are stored locally."
            case "settings.open_privacy_settings": return "Open Privacy Settings…"
            case "permission.welcome.title": return "Welcome to Mac Menubar Calendar"
            case "permission.welcome.description": return "Mac Menubar Calendar needs access to your calendars to display upcoming events in your menu bar. This app is strictly read-only and never modifies or deletes your data."
            case "permission.grant_button": return "Grant Calendar Access"
            case "permission.denied.title": return "Calendar Access Required"
            case "permission.denied.description": return "Calendar access was denied or restricted. Please enable calendar access in macOS System Settings > Privacy & Security > Calendars."
            case "permission.open_settings_button": return "Open System Settings"
            default: return key
            }
        }
    }

    public static func localizedFormat(_ key: String, language: AppLanguage? = nil, _ arguments: CVarArg...) -> String {
        let format = localized(key, language: language)
        return String(format: format, arguments: arguments)
    }
}

import Foundation

public struct LunarDateHelper {
    private static let chineseCalendar: Calendar = {
        var cal = Calendar(identifier: .chinese)
        cal.locale = Locale(identifier: "zh-Hant")
        return cal
    }()

    private static let lunarDays = [
        "", "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    private static let lunarMonths = [
        "", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月"
    ]

    /// Returns the lunar day string (e.g. "十三", "廿七", "七月", "初二")
    public static func lunarString(for date: Date) -> (text: String, isFirstDayOfMonth: Bool) {
        let day = chineseCalendar.component(.day, from: date)
        let month = chineseCalendar.component(.month, from: date)

        if day == 1 {
            let monthName = (month > 0 && month <= 12) ? lunarMonths[month] : "\(month)月"
            return (monthName, true)
        }

        if day > 0 && day < lunarDays.count {
            return (lunarDays[day], false)
        }

        return ("", false)
    }

    /// Formats solar day string (e.g. "8月1日" for 1st of month, or "26日")
    public static func solarDayString(for date: Date, calendar: Calendar, language: AppLanguage = AppStrings.currentLanguage) -> String {
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)

        let isZh = language.isChinese()

        if day == 1 {
            if isZh {
                return "\(month)月1日"
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
        } else {
            if isZh {
                return "\(day)日"
            } else {
                return "\(day)"
            }
        }
    }
}

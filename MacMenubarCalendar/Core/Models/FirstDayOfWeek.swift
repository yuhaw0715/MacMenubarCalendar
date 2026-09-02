import Foundation
import SwiftUI

public enum FirstDayOfWeek: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case sunday = "sunday"
    case monday = "monday"

    public var id: String { rawValue }

    public var localizedKey: String {
        switch self {
        case .system:
            return "settings.first_day_of_week.system"
        case .sunday:
            return "settings.first_day_of_week.sunday"
        case .monday:
            return "settings.first_day_of_week.monday"
        }
    }

    public var localizedTitleKey: LocalizedStringKey {
        LocalizedStringKey(localizedKey)
    }

    public var localizedTitle: String {
        AppStrings.localized(localizedKey)
    }

    public func effectiveWeekday(calendar: Calendar = .current) -> Int {
        switch self {
        case .system:
            return calendar.firstWeekday
        case .sunday:
            return 1
        case .monday:
            return 2
        }
    }
}

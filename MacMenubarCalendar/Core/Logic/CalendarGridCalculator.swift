import Foundation

public struct CalendarGridCalculator: Sendable {
    public static let totalDays = 28
    public static let columns = 7
    public static let rows = 4

    public init() {}

    public func startOfWeek(for date: Date, firstDayOfWeek: FirstDayOfWeek = .system, calendar: Calendar) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let currentWeekday = calendar.component(.weekday, from: startOfDay)
        let targetWeekday = firstDayOfWeek.effectiveWeekday(calendar: calendar)
        let daysBack = (currentWeekday - targetWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -daysBack, to: startOfDay) ?? startOfDay.addingTimeInterval(Double(-daysBack * 86400))
    }

    public func calculateGridDates(startDate: Date, calendar: Calendar) -> [Date] {
        let startOfFirstDay = calendar.startOfDay(for: startDate)
        var dates: [Date] = []
        dates.reserveCapacity(Self.totalDays)

        for dayOffset in 0..<Self.totalDays {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfFirstDay) {
                dates.append(date)
            }
        }
        return dates
    }

    public func calculateDateRange(startDate: Date, calendar: Calendar) -> (start: Date, end: Date) {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.date(byAdding: .day, value: Self.totalDays, to: start) ?? start.addingTimeInterval(TimeInterval(Self.totalDays * 86400))
        return (start: start, end: end)
    }

    public func nextWeek(from currentStart: Date, calendar: Calendar) -> Date {
        let startOfDay = calendar.startOfDay(for: currentStart)
        return calendar.date(byAdding: .day, value: 7, to: startOfDay) ?? startOfDay.addingTimeInterval(7 * 86400)
    }

    public func previousWeek(from currentStart: Date, calendar: Calendar) -> Date {
        let startOfDay = calendar.startOfDay(for: currentStart)
        return calendar.date(byAdding: .day, value: -7, to: startOfDay) ?? startOfDay.addingTimeInterval(-7 * 86400)
    }

    public func resetToToday(now: Date, firstDayOfWeek: FirstDayOfWeek = .system, calendar: Calendar) -> Date {
        startOfWeek(for: now, firstDayOfWeek: firstDayOfWeek, calendar: calendar)
    }

    public func weekdayHeaders(firstDayOfWeek: FirstDayOfWeek = .system, calendar: Calendar = .current, locale: Locale = .current) -> [String] {
        let referenceDate = Date(timeIntervalSince1970: 1700000000)
        var cal = calendar
        cal.locale = locale
        let weekStart = startOfWeek(for: referenceDate, firstDayOfWeek: firstDayOfWeek, calendar: cal)

        let formatter = DateFormatter()
        formatter.calendar = cal
        formatter.timeZone = cal.timeZone
        formatter.locale = locale
        formatter.dateFormat = "E"

        return (0..<Self.columns).compactMap { offset in
            guard let day = cal.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
            return formatter.string(from: day)
        }
    }

    public func monthTitle(for gridStartDate: Date, calendar: Calendar = .current, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = locale
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMM", options: 0, locale: locale) ?? "yyyy MMMM"
        return formatter.string(from: gridStartDate)
    }
}

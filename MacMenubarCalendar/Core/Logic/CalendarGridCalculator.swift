import Foundation

public struct CalendarGridCalculator: Sendable {
    public static let totalDays = 28
    public static let columns = 7
    public static let rows = 4

    public init() {}

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

    public func resetToToday(now: Date, calendar: Calendar) -> Date {
        calendar.startOfDay(for: now)
    }
}

import XCTest
@testable import MacMenubarCalendar

final class DateBoundaryTests: XCTestCase {
    var calculator: CalendarGridCalculator!

    override func setUp() {
        super.setUp()
        calculator = CalendarGridCalculator()
    }

    func testCrossMonthBoundary() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 20
        components.hour = 0
        components.minute = 0
        let jan20 = calendar.date(from: components)!

        let dates = calculator.calculateGridDates(startDate: jan20, calendar: calendar)
        XCTAssertEqual(dates.count, 28)

        // Date 0: Jan 20 -> Date 11: Jan 31 -> Date 12: Feb 1 -> Date 27: Feb 16
        let day12 = dates[12]
        XCTAssertEqual(calendar.component(.month, from: day12), 2)
        XCTAssertEqual(calendar.component(.day, from: day12), 1)

        let lastDay = dates.last!
        XCTAssertEqual(calendar.component(.month, from: lastDay), 2)
        XCTAssertEqual(calendar.component(.day, from: lastDay), 16)
    }

    func testCrossYearBoundary() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        var components = DateComponents()
        components.year = 2025
        components.month = 12
        components.day = 20
        let dec20 = calendar.date(from: components)!

        let dates = calculator.calculateGridDates(startDate: dec20, calendar: calendar)
        XCTAssertEqual(dates.count, 28)

        // Dec 20 (day 0) to Dec 31 (day 11) -> Jan 1, 2026 (day 12)
        let day12 = dates[12]
        XCTAssertEqual(calendar.component(.year, from: day12), 2026)
        XCTAssertEqual(calendar.component(.month, from: day12), 1)
        XCTAssertEqual(calendar.component(.day, from: day12), 1)

        let lastDay = dates.last!
        XCTAssertEqual(calendar.component(.year, from: lastDay), 2026)
        XCTAssertEqual(calendar.component(.month, from: lastDay), 1)
        XCTAssertEqual(calendar.component(.day, from: lastDay), 16)
    }

    func testLeapYearFebruary() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        // 2024 is a leap year
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 15
        let feb15 = calendar.date(from: components)!

        let dates = calculator.calculateGridDates(startDate: feb15, calendar: calendar)
        XCTAssertEqual(dates.count, 28)

        // Day 14 should be Feb 29
        let day14 = dates[14]
        XCTAssertEqual(calendar.component(.month, from: day14), 2)
        XCTAssertEqual(calendar.component(.day, from: day14), 29)

        // Day 15 should be Mar 1
        let day15 = dates[15]
        XCTAssertEqual(calendar.component(.month, from: day15), 3)
        XCTAssertEqual(calendar.component(.day, from: day15), 1)
    }

    func testDaylightSavingTimeSpringForward() {
        var calendar = Calendar(identifier: .gregorian)
        // New York DST Spring Forward in 2024 was on March 10 (23-hour day)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!

        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 5
        let start = calendar.date(from: components)!

        let dates = calculator.calculateGridDates(startDate: start, calendar: calendar)
        XCTAssertEqual(dates.count, 28)

        // Verify each date is at 00:00:00 local time
        for date in dates {
            let hour = calendar.component(.hour, from: date)
            XCTAssertEqual(hour, 0, "Each day in DST transition must start at hour 0")
        }
    }

    func testDaylightSavingTimeFallBack() {
        var calendar = Calendar(identifier: .gregorian)
        // New York DST Fall Back in 2024 was on November 3 (25-hour day)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!

        var components = DateComponents()
        components.year = 2024
        components.month = 10
        components.day = 28
        let start = calendar.date(from: components)!

        let dates = calculator.calculateGridDates(startDate: start, calendar: calendar)
        XCTAssertEqual(dates.count, 28)

        // Verify each date is at 00:00:00 local time
        for date in dates {
            let hour = calendar.component(.hour, from: date)
            XCTAssertEqual(hour, 0, "Each day in Fall Back DST transition must start at hour 0")
        }
    }

    func testTimeZoneChangeConsistency() {
        let utcCalendar = {
            var c = Calendar(identifier: .gregorian)
            c.timeZone = TimeZone(identifier: "UTC")!
            return c
        }()

        let tokyoCalendar = {
            var c = Calendar(identifier: .gregorian)
            c.timeZone = TimeZone(identifier: "Asia/Tokyo")!
            return c
        }()

        let now = Date(timeIntervalSince1970: 1700000000)

        let utcDates = calculator.calculateGridDates(startDate: now, calendar: utcCalendar)
        let tokyoDates = calculator.calculateGridDates(startDate: now, calendar: tokyoCalendar)

        XCTAssertEqual(utcDates.count, 28)
        XCTAssertEqual(tokyoDates.count, 28)

        XCTAssertEqual(utcCalendar.component(.hour, from: utcDates.first!), 0)
        XCTAssertEqual(tokyoCalendar.component(.hour, from: tokyoDates.first!), 0)
    }
}

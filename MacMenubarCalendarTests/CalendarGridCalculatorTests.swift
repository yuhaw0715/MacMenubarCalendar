import XCTest
@testable import MacMenubarCalendar

final class CalendarGridCalculatorTests: XCTestCase {
    var calculator: CalendarGridCalculator!
    var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calculator = CalendarGridCalculator()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Taipei")!
    }

    func testCalculateGridDatesReturnsExactly28Days() {
        let now = Date(timeIntervalSince1970: 1700000000) // 2023-11-14
        let dates = calculator.calculateGridDates(startDate: now, calendar: calendar)

        XCTAssertEqual(dates.count, 28)
        XCTAssertEqual(dates.count, CalendarGridCalculator.totalDays)
        XCTAssertEqual(CalendarGridCalculator.columns * CalendarGridCalculator.rows, 28)

        // First date must be start of day for startDate
        let startOfDay = calendar.startOfDay(for: now)
        XCTAssertEqual(dates.first, startOfDay)

        // Ensure consecutive days
        for i in 1..<dates.count {
            let prev = dates[i - 1]
            let curr = dates[i]
            let diff = calendar.dateComponents([.day], from: prev, to: curr)
            XCTAssertEqual(diff.day, 1)
        }
    }

    func testCalculateDateRangeReturnsHalfOpen28Days() {
        let now = Date(timeIntervalSince1970: 1700000000)
        let (start, end) = calculator.calculateDateRange(startDate: now, calendar: calendar)

        let startOfDay = calendar.startOfDay(for: now)
        XCTAssertEqual(start, startOfDay)

        let daysDiff = calendar.dateComponents([.day], from: start, to: end)
        XCTAssertEqual(daysDiff.day, 28)
    }

    func testNextWeekAdvances7Days() {
        let now = Date(timeIntervalSince1970: 1700000000)
        let startOfDay = calendar.startOfDay(for: now)
        let next = calculator.nextWeek(from: startOfDay, calendar: calendar)

        let diff = calendar.dateComponents([.day], from: startOfDay, to: next)
        XCTAssertEqual(diff.day, 7)
    }

    func testPreviousWeekRewinds7Days() {
        let now = Date(timeIntervalSince1970: 1700000000)
        let startOfDay = calendar.startOfDay(for: now)
        let prev = calculator.previousWeek(from: startOfDay, calendar: calendar)

        let diff = calendar.dateComponents([.day], from: startOfDay, to: prev)
        XCTAssertEqual(diff.day, -7)
    }

    func testResetToTodayReturnsStartOfToday() {
        let now = Date(timeIntervalSince1970: 1700000000)
        let today = calculator.resetToToday(now: now, calendar: calendar)

        let startOfDay = calendar.startOfDay(for: now)
        XCTAssertEqual(today, startOfDay)
    }
}

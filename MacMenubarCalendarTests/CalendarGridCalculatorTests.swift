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

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = 0
        comps.second = 0
        return calendar.date(from: comps)!
    }

    func testStartOfWeekForSundayAndMondayModes() {
        // 2026-09-02 is Wednesday (weekday 4 in Gregorian calendar)
        let wednesday = makeDate(year: 2026, month: 9, day: 2)

        // Sunday mode: start of week must be Sunday 2026-08-30
        let weekStartSun = calculator.startOfWeek(for: wednesday, firstDayOfWeek: .sunday, calendar: calendar)
        XCTAssertEqual(calendar.component(.year, from: weekStartSun), 2026)
        XCTAssertEqual(calendar.component(.month, from: weekStartSun), 8)
        XCTAssertEqual(calendar.component(.day, from: weekStartSun), 30)
        XCTAssertEqual(calendar.component(.weekday, from: weekStartSun), 1)

        // Monday mode: start of week must be Monday 2026-08-31
        let weekStartMon = calculator.startOfWeek(for: wednesday, firstDayOfWeek: .monday, calendar: calendar)
        XCTAssertEqual(calendar.component(.year, from: weekStartMon), 2026)
        XCTAssertEqual(calendar.component(.month, from: weekStartMon), 8)
        XCTAssertEqual(calendar.component(.day, from: weekStartMon), 31)
        XCTAssertEqual(calendar.component(.weekday, from: weekStartMon), 2)
    }

    func testStartOfWeekWhenDateIsBoundaryDays() {
        // Sunday 2026-08-30 (weekday 1)
        let sunday = makeDate(year: 2026, month: 8, day: 30)
        let sunStartInSunMode = calculator.startOfWeek(for: sunday, firstDayOfWeek: .sunday, calendar: calendar)
        XCTAssertEqual(calendar.component(.day, from: sunStartInSunMode), 30)

        let sunStartInMonMode = calculator.startOfWeek(for: sunday, firstDayOfWeek: .monday, calendar: calendar)
        XCTAssertEqual(calendar.component(.day, from: sunStartInMonMode), 24) // Previous Monday Aug 24

        // Saturday 2026-09-05 (weekday 7)
        let saturday = makeDate(year: 2026, month: 9, day: 5)
        let satStartInSunMode = calculator.startOfWeek(for: saturday, firstDayOfWeek: .sunday, calendar: calendar)
        XCTAssertEqual(calendar.component(.day, from: satStartInSunMode), 30)

        let satStartInMonMode = calculator.startOfWeek(for: saturday, firstDayOfWeek: .monday, calendar: calendar)
        XCTAssertEqual(calendar.component(.day, from: satStartInMonMode), 31)
    }

    func testStartOfWeekSystemModeRespectsCalendarFirstWeekday() {
        let wednesday = makeDate(year: 2026, month: 9, day: 2)

        var usCalendar = calendar!
        usCalendar.firstWeekday = 1 // Sunday
        let usStart = calculator.startOfWeek(for: wednesday, firstDayOfWeek: .system, calendar: usCalendar)
        XCTAssertEqual(usCalendar.component(.day, from: usStart), 30)

        var frCalendar = calendar!
        frCalendar.firstWeekday = 2 // Monday
        let frStart = calculator.startOfWeek(for: wednesday, firstDayOfWeek: .system, calendar: frCalendar)
        XCTAssertEqual(frCalendar.component(.day, from: frStart), 31)
    }

    func testCalculateGridDatesReturnsExactly28Days() {
        let now = makeDate(year: 2026, month: 9, day: 2)
        let weekStart = calculator.startOfWeek(for: now, firstDayOfWeek: .sunday, calendar: calendar)
        let dates = calculator.calculateGridDates(startDate: weekStart, calendar: calendar)

        XCTAssertEqual(dates.count, 28)
        XCTAssertEqual(dates.count, CalendarGridCalculator.totalDays)
        XCTAssertEqual(CalendarGridCalculator.columns * CalendarGridCalculator.rows, 28)

        // First date must be start of day for weekStart (Aug 30)
        let startOfDay = calendar.startOfDay(for: weekStart)
        XCTAssertEqual(dates.first, startOfDay)
        XCTAssertEqual(calendar.component(.day, from: dates[0]), 30)
        XCTAssertEqual(calendar.component(.day, from: dates[3]), 2) // Sep 2 (Today) is at column index 3 (4th cell)

        // Ensure consecutive days
        for i in 1..<dates.count {
            let prev = dates[i - 1]
            let curr = dates[i]
            let diff = calendar.dateComponents([.day], from: prev, to: curr)
            XCTAssertEqual(diff.day, 1)
        }
    }

    func testCalculateDateRangeReturnsHalfOpen28Days() {
        let now = makeDate(year: 2026, month: 9, day: 2)
        let weekStart = calculator.startOfWeek(for: now, firstDayOfWeek: .sunday, calendar: calendar)
        let (start, end) = calculator.calculateDateRange(startDate: weekStart, calendar: calendar)

        let startOfDay = calendar.startOfDay(for: weekStart)
        XCTAssertEqual(start, startOfDay)

        let daysDiff = calendar.dateComponents([.day], from: start, to: end)
        XCTAssertEqual(daysDiff.day, 28)
    }

    func testNextWeekAdvances7Days() {
        let now = makeDate(year: 2026, month: 9, day: 2)
        let weekStart = calculator.startOfWeek(for: now, firstDayOfWeek: .sunday, calendar: calendar)
        let next = calculator.nextWeek(from: weekStart, calendar: calendar)

        let diff = calendar.dateComponents([.day], from: weekStart, to: next)
        XCTAssertEqual(diff.day, 7)
        XCTAssertEqual(calendar.component(.weekday, from: next), calendar.component(.weekday, from: weekStart))
    }

    func testPreviousWeekRewinds7Days() {
        let now = makeDate(year: 2026, month: 9, day: 2)
        let weekStart = calculator.startOfWeek(for: now, firstDayOfWeek: .sunday, calendar: calendar)
        let prev = calculator.previousWeek(from: weekStart, calendar: calendar)

        let diff = calendar.dateComponents([.day], from: weekStart, to: prev)
        XCTAssertEqual(diff.day, -7)
        XCTAssertEqual(calendar.component(.weekday, from: prev), calendar.component(.weekday, from: weekStart))
    }

    func testResetToTodayReturnsStartOfWeekForToday() {
        let now = makeDate(year: 2026, month: 9, day: 2)
        let todayGridStart = calculator.resetToToday(now: now, firstDayOfWeek: .sunday, calendar: calendar)

        XCTAssertEqual(calendar.component(.month, from: todayGridStart), 8)
        XCTAssertEqual(calendar.component(.day, from: todayGridStart), 30)
    }

    func testWeekdayHeadersDynamicOrdering() {
        let enLocale = Locale(identifier: "en_US")
        let headersSunday = calculator.weekdayHeaders(firstDayOfWeek: .sunday, calendar: calendar, locale: enLocale)
        XCTAssertEqual(headersSunday.count, 7)
        XCTAssertEqual(headersSunday.first, "Sun")
        XCTAssertEqual(headersSunday.last, "Sat")

        let headersMonday = calculator.weekdayHeaders(firstDayOfWeek: .monday, calendar: calendar, locale: enLocale)
        XCTAssertEqual(headersMonday.count, 7)
        XCTAssertEqual(headersMonday.first, "Mon")
        XCTAssertEqual(headersMonday.last, "Sun")
    }

    func testMonthTitleFormattedBasedOnFirstCellOfGrid() {
        let gridStartAug30 = makeDate(year: 2026, month: 8, day: 30)

        let zhLocale = Locale(identifier: "zh_Hant")
        let titleZh = calculator.monthTitle(for: gridStartAug30, calendar: calendar, locale: zhLocale)
        XCTAssertTrue(titleZh.contains("2026"))
        XCTAssertTrue(titleZh.contains("8"))

        let enLocale = Locale(identifier: "en_US")
        let titleEn = calculator.monthTitle(for: gridStartAug30, calendar: calendar, locale: enLocale)
        XCTAssertTrue(titleEn.contains("August"))
        XCTAssertTrue(titleEn.contains("2026"))
    }
}

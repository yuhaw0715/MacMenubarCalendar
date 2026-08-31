import XCTest
@testable import MacMenubarCalendar

final class PerformanceBenchmarkTests: XCTestCase {
    @MainActor
    func testLargeDatasetQueryAndMappingPerformance() async {
        let mockClock = MockClock()
        let calendar = mockClock.calendar
        let baseDate = calendar.startOfDay(for: mockClock.now)

        // Generate 1,500 events spread across -30 to +60 days
        var generatedEvents: [CalendarEvent] = []
        generatedEvents.reserveCapacity(1500)

        for i in 0..<1500 {
            let dayOffset = (i % 90) - 30
            let startHour = (i % 12) + 8
            let durationHours = (i % 3) + 1
            let isAllDay = (i % 10 == 0)

            guard let eventDay = calendar.date(byAdding: .day, value: dayOffset, to: baseDate),
                  let startDate = calendar.date(byAdding: .hour, value: startHour, to: eventDay),
                  let endDate = calendar.date(byAdding: .hour, value: durationHours, to: startDate) else {
                continue
            }

            let event = CalendarEvent(
                id: "event_\(i)",
                calendarId: "cal_\(i % 5)",
                calendarTitle: "Calendar \(i % 5)",
                calendarColorHex: "#3478F6",
                title: "Event Title \(i)",
                startDate: startDate,
                endDate: endDate,
                isAllDay: isAllDay,
                location: "Location \(i)"
            )
            generatedEvents.append(event)
        }

        let mockService = MockCalendarService(
            calendars: (0..<5).map { CalendarSource(id: "cal_\($0)", title: "Cal \($0)", colorHex: "#3478F6") },
            events: generatedEvents
        )

        let store = MockPreferencesStore()
        let viewModel = CalendarViewModel(
            calendarService: mockService,
            clock: mockClock,
            preferencesStore: store
        )

        // Measure mapping and rebuilding day cells
        let startTime = CFAbsoluteTimeGetCurrent()
        await viewModel.refreshData()
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(viewModel.dayCells.count, 28)
        XCTAssertLessThan(elapsed, 0.5, "28-day mapping with 1,500 events must complete in < 500ms (took \(elapsed)s)")
    }

    func testGridCalculationAndSortingBenchmark() {
        let filterAndSorter = EventFilterAndSorter()
        let gridCalculator = CalendarGridCalculator()
        let layoutEngine = DayLayoutEngine()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let baseDate = Date(timeIntervalSince1970: 1700000000)

        // Generate 2,000 events
        var events: [CalendarEvent] = []
        events.reserveCapacity(2000)
        for i in 0..<2000 {
            let dayOffset = (i % 60) - 15
            let day = calendar.date(byAdding: .day, value: dayOffset, to: baseDate)!
            let start = calendar.date(byAdding: .hour, value: (i % 12) + 8, to: day)!
            let end = calendar.date(byAdding: .hour, value: 2, to: start)!

            events.append(CalendarEvent(
                id: "\(i)",
                calendarId: "cal_\(i % 5)",
                calendarTitle: "Cal",
                calendarColorHex: "#000",
                title: "Event \(i)",
                startDate: start,
                endDate: end,
                isAllDay: (i % 8 == 0)
            ))
        }

        measure {
            let dates = gridCalculator.calculateGridDates(startDate: baseDate, calendar: calendar)
            var cells: [DayCellData] = []
            for date in dates {
                let dayEvents = filterAndSorter.eventsForDay(date, from: events, calendar: calendar)
                let layout = layoutEngine.calculateLayout(events: dayEvents, availableHeight: 80.0)
                cells.append(DayCellData(
                    date: date,
                    dayNumber: calendar.component(.day, from: date),
                    isToday: false,
                    events: dayEvents,
                    visibleEvents: layout.visible,
                    hiddenCount: layout.hiddenCount
                ))
            }
            XCTAssertEqual(cells.count, 28)
        }
    }
}

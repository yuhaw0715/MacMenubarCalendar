import XCTest
@testable import MacMenubarCalendar

final class EventFilterAndSorterTests: XCTestCase {
    var filterAndSorter: EventFilterAndSorter!
    var layoutEngine: DayLayoutEngine!
    var calendar: Calendar!

    override func setUp() {
        super.setUp()
        filterAndSorter = EventFilterAndSorter()
        layoutEngine = DayLayoutEngine()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
    }

    func testSortEventsAllDayFirstThenByStartTime() {
        let baseDate = Date(timeIntervalSince1970: 1700000000)

        let timedEvent2 = CalendarEvent(
            id: "2",
            calendarId: "cal1",
            calendarTitle: "Personal",
            calendarColorHex: "#FF0000",
            title: "Lunch Meeting",
            startDate: baseDate.addingTimeInterval(3600 * 12),
            endDate: baseDate.addingTimeInterval(3600 * 13),
            isAllDay: false
        )

        let timedEvent1 = CalendarEvent(
            id: "1",
            calendarId: "cal1",
            calendarTitle: "Personal",
            calendarColorHex: "#FF0000",
            title: "Breakfast",
            startDate: baseDate.addingTimeInterval(3600 * 8),
            endDate: baseDate.addingTimeInterval(3600 * 9),
            isAllDay: false
        )

        let allDayEvent = CalendarEvent(
            id: "3",
            calendarId: "cal1",
            calendarTitle: "Personal",
            calendarColorHex: "#FF0000",
            title: "Holiday",
            startDate: baseDate,
            endDate: baseDate.addingTimeInterval(3600 * 24),
            isAllDay: true
        )

        let events = [timedEvent2, timedEvent1, allDayEvent]
        let sorted = filterAndSorter.sortEventsForDay(events)

        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].id, "3", "All-day event should come first")
        XCTAssertEqual(sorted[1].id, "1", "Earlier timed event should come second")
        XCTAssertEqual(sorted[2].id, "2", "Later timed event should come third")
    }

    func testFilterEventsBySelectedCalendars() {
        let baseDate = Date()
        let eventA = CalendarEvent(id: "A", calendarId: "work", calendarTitle: "Work", calendarColorHex: "#00FF00", title: "Work meeting", startDate: baseDate, endDate: baseDate.addingTimeInterval(3600), isAllDay: false)
        let eventB = CalendarEvent(id: "B", calendarId: "home", calendarTitle: "Home", calendarColorHex: "#0000FF", title: "Home chore", startDate: baseDate, endDate: baseDate.addingTimeInterval(3600), isAllDay: false)

        let all = [eventA, eventB]

        let filteredWorkOnly = filterAndSorter.filterEvents(all, selectedCalendarIds: ["work"], showDeclinedEvents: true)
        XCTAssertEqual(filteredWorkOnly.count, 1)
        XCTAssertEqual(filteredWorkOnly.first?.id, "A")

        let filteredNone = filterAndSorter.filterEvents(all, selectedCalendarIds: [], showDeclinedEvents: true)
        XCTAssertTrue(filteredNone.isEmpty)

        let filteredAll = filterAndSorter.filterEvents(all, selectedCalendarIds: nil, showDeclinedEvents: true)
        XCTAssertEqual(filteredAll.count, 2)
    }

    func testFilterEventsByDeclinedStatus() {
        let baseDate = Date()
        let activeEvent = CalendarEvent(id: "1", calendarId: "work", calendarTitle: "Work", calendarColorHex: "#00FF00", title: "Team Sync", startDate: baseDate, endDate: baseDate.addingTimeInterval(3600), isAllDay: false, isStatusDeclined: false)
        let declinedEvent = CalendarEvent(id: "2", calendarId: "work", calendarTitle: "Work", calendarColorHex: "#00FF00", title: "Optional Webinar", startDate: baseDate, endDate: baseDate.addingTimeInterval(3600), isAllDay: false, isStatusDeclined: true)

        let all = [activeEvent, declinedEvent]

        let hiddenDeclined = filterAndSorter.filterEvents(all, selectedCalendarIds: nil, showDeclinedEvents: false)
        XCTAssertEqual(hiddenDeclined.count, 1)
        XCTAssertEqual(hiddenDeclined.first?.id, "1")

        let showDeclined = filterAndSorter.filterEvents(all, selectedCalendarIds: nil, showDeclinedEvents: true)
        XCTAssertEqual(showDeclined.count, 2)
    }

    func testMultiDayEventSpansMultipleDays() {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 10
        components.hour = 0
        components.minute = 0
        let day1 = calendar.date(from: components)!
        let day2 = calendar.date(byAdding: .day, value: 1, to: day1)!
        let day3 = calendar.date(byAdding: .day, value: 2, to: day1)!
        let day4 = calendar.date(byAdding: .day, value: 3, to: day1)!

        // Event from day 1 to day 3 (3 days long)
        let spanningEvent = CalendarEvent(
            id: "conference",
            calendarId: "work",
            calendarTitle: "Work",
            calendarColorHex: "#FF00FF",
            title: "Tech Conference",
            startDate: day1.addingTimeInterval(3600 * 9),
            endDate: day3.addingTimeInterval(3600 * 18),
            isAllDay: false
        )

        let allEvents = [spanningEvent]

        let day1Events = filterAndSorter.eventsForDay(day1, from: allEvents, calendar: calendar)
        let day2Events = filterAndSorter.eventsForDay(day2, from: allEvents, calendar: calendar)
        let day3Events = filterAndSorter.eventsForDay(day3, from: allEvents, calendar: calendar)
        let day4Events = filterAndSorter.eventsForDay(day4, from: allEvents, calendar: calendar)

        XCTAssertEqual(day1Events.count, 1, "Should appear on Day 1")
        XCTAssertEqual(day2Events.count, 1, "Should appear on Day 2")
        XCTAssertEqual(day3Events.count, 1, "Should appear on Day 3")
        XCTAssertEqual(day4Events.count, 0, "Should NOT appear on Day 4")
    }

    func testDayLayoutEngineOverflow() {
        let dummyEvents = (1...6).map { i in
            CalendarEvent(id: "\(i)", calendarId: "c", calendarTitle: "C", calendarColorHex: "#000", title: "Event \(i)", startDate: Date(), endDate: Date(), isAllDay: false)
        }

        // Available height 80pt, rowHeight 20pt, header 26pt -> contentHeight 54pt -> maxSlots = 2
        let (visible, hidden) = layoutEngine.calculateLayout(events: dummyEvents, availableHeight: 80, rowHeight: 20, headerHeight: 26)

        // With 6 events and 2 slots: slotsForEvents = 1, hidden = 5
        XCTAssertEqual(visible.count, 1)
        XCTAssertEqual(hidden, 5)
        XCTAssertEqual(visible.count + hidden, 6)

        // When all events fit:
        let smallList = [dummyEvents[0]]
        let (visSmall, hidSmall) = layoutEngine.calculateLayout(events: smallList, availableHeight: 80, rowHeight: 20, headerHeight: 26)
        XCTAssertEqual(visSmall.count, 1)
        XCTAssertEqual(hidSmall, 0)
    }
}

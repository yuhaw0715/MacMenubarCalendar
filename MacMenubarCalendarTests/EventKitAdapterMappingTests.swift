import XCTest
@testable import MacMenubarCalendar

final class EventKitAdapterMappingTests: XCTestCase {
    func testCalendarSourceHexColorConversion() {
        let source = CalendarSource(id: "cal1", title: "Personal", colorHex: "#FF0000", accountTitle: "iCloud")
        XCTAssertEqual(source.id, "cal1")
        XCTAssertEqual(source.title, "Personal")
        XCTAssertEqual(source.colorHex, "#FF0000")
        XCTAssertEqual(source.accountTitle, "iCloud")

        let invalidSource = CalendarSource(id: "cal2", title: "Other", colorHex: "invalid")
        _ = invalidSource.swiftUIColor // Shouldn't crash, falls back to .blue
    }

    func testCalendarEventImmutability() {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        let event = CalendarEvent(
            id: "evt1",
            calendarId: "cal1",
            calendarTitle: "Work",
            calendarColorHex: "#3478F6",
            title: "Sprint Planning",
            startDate: start,
            endDate: end,
            isAllDay: false,
            location: "Room 101",
            isStatusDeclined: false
        )

        XCTAssertEqual(event.id, "evt1")
        XCTAssertEqual(event.title, "Sprint Planning")
        XCTAssertEqual(event.location, "Room 101")
        XCTAssertFalse(event.isStatusDeclined)
        XCTAssertFalse(event.isAllDay)
    }

    @MainActor
    func testEventsAreMemoryOnlyAndNotPersistedToUserDefaults() async {
        let suiteName = "test_memory_only_\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let store = AppPreferencesStore(userDefaults: userDefaults)
        let mockClock = MockClock()
        let mockService = MockCalendarService()
        let mockOpener = MockCalendarOpener()
        let mockLogin = MockLoginItemManager()

        let testEvent = CalendarEvent(
            id: "secret_event_123",
            calendarId: "cal1",
            calendarTitle: "Work",
            calendarColorHex: "#000",
            title: "Super Secret Confidential Meeting",
            startDate: mockClock.now,
            endDate: mockClock.now.addingTimeInterval(3600),
            isAllDay: false,
            location: "Secret Bunker"
        )

        mockService.stubbedCalendars = [CalendarSource(id: "cal1", title: "Work", colorHex: "#000")]
        mockService.stubbedEvents = [testEvent]

        let viewModel = CalendarViewModel(
            calendarService: mockService,
            clock: mockClock,
            preferencesStore: store,
            loginItemManager: mockLogin,
            calendarOpener: mockOpener
        )

        await viewModel.refreshData()

        let todayCell = viewModel.dayCells.first { $0.isToday }
        XCTAssertEqual(todayCell?.events.first?.title, "Super Secret Confidential Meeting")

        // Verify that neither the title, location, nor event id is present in userDefaults dictionary!
        let allKeys = userDefaults.dictionaryRepresentation()
        for (key, value) in allKeys {
            let stringVal = "\(value)"
            XCTAssertFalse(stringVal.contains("Super Secret Confidential Meeting"), "Event title must not be persisted to disk/UserDefaults in key: \(key)")
            XCTAssertFalse(stringVal.contains("Secret Bunker"), "Event location must not be persisted to disk/UserDefaults in key: \(key)")
            XCTAssertFalse(stringVal.contains("secret_event_123"), "Event ID must not be persisted in key: \(key)")
        }
    }
}

import XCTest
@testable import MacMenubarCalendar

final class PreferencesTests: XCTestCase {
    var userDefaults: UserDefaults!
    var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "test_prefs_\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    @MainActor
    func testPreferencesDefaults() {
        let store = AppPreferencesStore(userDefaults: userDefaults)
        XCTAssertFalse(store.showDeclinedEvents)
        XCTAssertEqual(store.appearanceMode, .system)
        XCTAssertFalse(store.launchAtLogin)
        XCTAssertFalse(store.isPinned)
        XCTAssertEqual(store.windowWidth, 720.0)
        XCTAssertEqual(store.windowHeight, 500.0)
    }

    @MainActor
    func testPreferencesMutationAndPersistence() {
        let store = AppPreferencesStore(userDefaults: userDefaults)
        store.showDeclinedEvents = true
        store.appearanceMode = .dark
        store.isPinned = true
        store.windowWidth = 800.0
        store.windowHeight = 600.0
        store.selectedCalendarIds = ["cal_1", "cal_2"]

        // Recreate store using same suite
        let reloadedStore = AppPreferencesStore(userDefaults: userDefaults)
        XCTAssertTrue(reloadedStore.showDeclinedEvents)
        XCTAssertEqual(reloadedStore.appearanceMode, .dark)
        XCTAssertTrue(reloadedStore.isPinned)
        XCTAssertEqual(reloadedStore.windowWidth, 800.0)
        XCTAssertEqual(reloadedStore.windowHeight, 600.0)
        XCTAssertEqual(reloadedStore.selectedCalendarIds, ["cal_1", "cal_2"])
    }

    @MainActor
    func testCalendarSyncPruningAndNewCalendarDefaultSelection() async {
        let store = AppPreferencesStore(userDefaults: userDefaults)
        store.selectedCalendarIds = ["cal_existing"]

        let mockClock = MockClock()
        let mockService = MockCalendarService()
        // Available calendars in system has "cal_existing" and a newly added "cal_new", but "cal_deleted" is gone
        mockService.stubbedCalendars = [
            CalendarSource(id: "cal_existing", title: "Existing", colorHex: "#000"),
            CalendarSource(id: "cal_new", title: "New Calendar", colorHex: "#FFF")
        ]

        let viewModel = CalendarViewModel(
            calendarService: mockService,
            clock: mockClock,
            preferencesStore: store
        )

        await viewModel.refreshData()

        // Selection should contain "cal_existing" and "cal_new"
        XCTAssertEqual(viewModel.selectedCalendarIds, ["cal_existing", "cal_new"])
        XCTAssertEqual(store.selectedCalendarIds, ["cal_existing", "cal_new"])
    }
}

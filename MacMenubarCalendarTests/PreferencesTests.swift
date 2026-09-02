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
        XCTAssertEqual(store.appLanguage, .system)
        XCTAssertEqual(store.firstDayOfWeek, .system)
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
        store.appLanguage = .en
        store.firstDayOfWeek = .monday
        store.isPinned = true
        store.windowWidth = 800.0
        store.windowHeight = 600.0
        store.selectedCalendarIds = ["cal_1", "cal_2"]

        // Recreate store using same suite
        let reloadedStore = AppPreferencesStore(userDefaults: userDefaults)
        XCTAssertTrue(reloadedStore.showDeclinedEvents)
        XCTAssertEqual(reloadedStore.appearanceMode, .dark)
        XCTAssertEqual(reloadedStore.appLanguage, .en)
        XCTAssertEqual(reloadedStore.firstDayOfWeek, .monday)
        XCTAssertTrue(reloadedStore.isPinned)
        XCTAssertEqual(reloadedStore.windowWidth, 800.0)
        XCTAssertEqual(reloadedStore.windowHeight, 600.0)
        XCTAssertEqual(reloadedStore.selectedCalendarIds, ["cal_1", "cal_2"])
    }

    @MainActor
    func testFirstDayOfWeekViewModelReactivity() {
        let store = AppPreferencesStore(userDefaults: userDefaults)
        let mockClock = MockClock(now: Date(timeIntervalSince1970: 1700000000)) // 2023-11-14 Tue
        let mockService = MockCalendarService()

        let viewModel = CalendarViewModel(
            calendarService: mockService,
            clock: mockClock,
            preferencesStore: store
        )

        XCTAssertEqual(viewModel.firstDayOfWeek, .system)

        viewModel.setFirstDayOfWeek(.monday)
        XCTAssertEqual(viewModel.firstDayOfWeek, .monday)
        XCTAssertEqual(store.firstDayOfWeek, .monday)

        // 2023-11-14 was Tuesday. Monday of that week was 2023-11-13.
        let cal = mockClock.calendar
        let startDay = cal.component(.day, from: viewModel.startDate)
        XCTAssertEqual(startDay, 13)

        viewModel.setFirstDayOfWeek(.sunday)
        XCTAssertEqual(viewModel.firstDayOfWeek, .sunday)
        XCTAssertEqual(store.firstDayOfWeek, .sunday)

        // Sunday of that week was 2023-11-12.
        let sunStartDay = cal.component(.day, from: viewModel.startDate)
        XCTAssertEqual(sunStartDay, 12)
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

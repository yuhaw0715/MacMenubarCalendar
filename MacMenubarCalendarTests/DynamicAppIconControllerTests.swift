import XCTest
@testable import MacMenubarCalendar

final class DynamicAppIconControllerTests: XCTestCase {

    @MainActor
    func testInitialUpdateRendersAndAppliesIcon() {
        var appliedImage: NSImage?
        let mockClock = MockClock()
        let testDate = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 3))!
        mockClock.now = testDate

        let store = MockPreferencesStore(appLanguage: .zhHant)
        let notificationCenter = NotificationCenter()

        let controller = DynamicAppIconController(
            notificationCenter: notificationCenter,
            workspaceNotificationCenter: nil,
            clock: mockClock,
            preferencesStore: store,
            iconApplicator: { img in
                appliedImage = img
            }
        )

        XCTAssertNotNil(appliedImage)
        XCTAssertEqual(controller.updateCount, 1)
        XCTAssertEqual(controller.currentRenderedLanguage, .zhHant)
        XCTAssertEqual(controller.currentRenderedDate, testDate)
    }

    @MainActor
    func testNotificationTriggersUpdate() {
        var appliedImages = [NSImage]()
        let mockClock = MockClock()
        let initialDate = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 3))!
        mockClock.now = initialDate

        let store = MockPreferencesStore(appLanguage: .en)
        let notificationCenter = NotificationCenter()
        let wsNotificationCenter = NotificationCenter()

        let controller = DynamicAppIconController(
            notificationCenter: notificationCenter,
            workspaceNotificationCenter: wsNotificationCenter,
            clock: mockClock,
            preferencesStore: store,
            iconApplicator: { img in
                appliedImages.append(img)
            }
        )

        XCTAssertEqual(controller.updateCount, 1)

        // Simulate day change
        let nextDay = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 4))!
        mockClock.now = nextDay
        notificationCenter.post(name: .NSCalendarDayChanged, object: nil)

        // Allow run loop to process notification sink
        let expectation1 = XCTestExpectation(description: "Day changed update")
        DispatchQueue.main.async {
            XCTAssertEqual(controller.updateCount, 2)
            XCTAssertEqual(controller.currentRenderedDate, nextDay)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)

        // Simulate workspace wake
        wsNotificationCenter.post(name: NSWorkspace.didWakeNotification, object: nil)
        let expectation2 = XCTestExpectation(description: "Wake update")
        DispatchQueue.main.async {
            XCTAssertEqual(controller.updateCount, 3)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
    }

    @MainActor
    func testLanguageChangeUpdate() {
        var appliedImages = [NSImage]()
        let mockClock = MockClock()
        let testDate = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 3))!
        mockClock.now = testDate

        let store = MockPreferencesStore(appLanguage: .zhHant)
        let notificationCenter = NotificationCenter()

        let controller = DynamicAppIconController(
            notificationCenter: notificationCenter,
            workspaceNotificationCenter: nil,
            clock: mockClock,
            preferencesStore: store,
            iconApplicator: { img in
                appliedImages.append(img)
            }
        )

        XCTAssertEqual(controller.currentRenderedLanguage, .zhHant)

        // Force update with new language
        controller.updateIcon(forceLanguage: .en)
        XCTAssertEqual(controller.updateCount, 2)
        XCTAssertEqual(controller.currentRenderedLanguage, .en)
    }
}

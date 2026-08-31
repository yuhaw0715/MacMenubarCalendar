import XCTest

final class MacMenubarCalendarUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchAndBasicPresence() throws {
        let app = XCUIApplication()
        app.launch()

        // As a menu bar app (LSUIElement = YES), app runs in accessory mode
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5.0) || app.state == .runningBackground || app.state == .runningForeground)
    }
}

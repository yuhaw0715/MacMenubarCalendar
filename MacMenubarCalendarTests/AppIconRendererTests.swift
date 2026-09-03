import XCTest
@testable import MacMenubarCalendar

final class AppIconRendererTests: XCTestCase {

    @MainActor
    func testRenderAppIconGeneratesValidImage() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 3))!

        let icon = AppIconRenderer.renderAppIcon(
            date: date,
            calendar: .current,
            language: .zhHant,
            targetSize: NSSize(width: 512, height: 512)
        )

        XCTAssertEqual(icon.size.width, 512)
        XCTAssertEqual(icon.size.height, 512)
        XCTAssertNotNil(icon.tiffRepresentation)
    }

    @MainActor
    func testRenderAppIconLanguages() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 3))!

        let zhIcon = AppIconRenderer.renderAppIcon(
            date: date,
            calendar: .current,
            language: .zhHant
        )
        XCTAssertNotNil(zhIcon.tiffRepresentation)

        let enIcon = AppIconRenderer.renderAppIcon(
            date: date,
            calendar: .current,
            language: .en
        )
        XCTAssertNotNil(enIcon.tiffRepresentation)
    }

    @MainActor
    func testRenderIconSetGeneratesAllStandardSizes() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 3))!

        let iconSet = AppIconRenderer.renderIconSet(
            date: date,
            calendar: .current,
            language: .system
        )

        let expectedSizes = [16, 32, 64, 128, 256, 512, 1024]
        XCTAssertEqual(iconSet.count, expectedSizes.count)

        for size in expectedSizes {
            guard let img = iconSet[size] else {
                XCTFail("Missing icon for size \(size)")
                continue
            }
            XCTAssertEqual(img.size.width, CGFloat(size))
            XCTAssertEqual(img.size.height, CGFloat(size))
            XCTAssertNotNil(img.tiffRepresentation)
        }
    }
}

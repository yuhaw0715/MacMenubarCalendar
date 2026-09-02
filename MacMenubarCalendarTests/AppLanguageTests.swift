import XCTest
@testable import MacMenubarCalendar

final class AppLanguageTests: XCTestCase {

    func testEffectiveLocaleForExplicitLanguages() {
        XCTAssertEqual(AppLanguage.zhHant.effectiveLocale().identifier, "zh-Hant")
        XCTAssertTrue(AppLanguage.zhHant.isChinese())

        XCTAssertEqual(AppLanguage.en.effectiveLocale().identifier, "en")
        XCTAssertFalse(AppLanguage.en.isChinese())
    }

    func testEffectiveLocaleForSystemModeWithChinese() {
        let chineseVariants = [
            ["zh-Hant-TW", "en-US"],
            ["zh-Hans-CN", "en-US"],
            ["zh-TW", "en"],
            ["zh-HK", "en"],
            ["zh", "en"]
        ]

        for preferred in chineseVariants {
            let locale = AppLanguage.system.effectiveLocale(preferredLanguages: preferred)
            XCTAssertEqual(locale.identifier, "zh-Hant", "Failed for preferred: \(preferred)")
            XCTAssertTrue(AppLanguage.system.isChinese(preferredLanguages: preferred))
        }
    }

    func testEffectiveLocaleForSystemModeWithNonChineseFallback() {
        let nonChineseVariants = [
            ["en-US", "zh-Hant"],
            ["ja-JP", "en-US"],
            ["fr-FR", "de-DE"],
            ["de-DE"],
            ["es-ES"]
        ]

        for preferred in nonChineseVariants {
            let locale = AppLanguage.system.effectiveLocale(preferredLanguages: preferred)
            XCTAssertEqual(locale.identifier, "en", "Expected fallback to en for: \(preferred)")
            XCTAssertFalse(AppLanguage.system.isChinese(preferredLanguages: preferred))
        }
    }

    func testAppStringsResolutionAndFallbacks() {
        // Test Chinese resolution
        XCTAssertEqual(AppStrings.localized("header.nav.today", language: .zhHant), "今天")
        XCTAssertEqual(AppStrings.localized("action.quit", language: .zhHant), "結束 App")
        XCTAssertEqual(AppStrings.localized("settings.language.title", language: .zhHant), "語言")

        // Test English resolution
        XCTAssertEqual(AppStrings.localized("header.nav.today", language: .en), "Today")
        XCTAssertEqual(AppStrings.localized("action.quit", language: .en), "Quit App")
        XCTAssertEqual(AppStrings.localized("settings.language.title", language: .en), "Language")
    }

    @MainActor
    func testViewModelAppLanguageSwitching() {
        let mockClock = MockClock()
        let mockService = MockCalendarService()
        let store = MockPreferencesStore(appLanguage: .system)

        let viewModel = CalendarViewModel(
            calendarService: mockService,
            clock: mockClock,
            preferencesStore: store
        )

        XCTAssertEqual(viewModel.appLanguage, .system)

        viewModel.setAppLanguage(.en)
        XCTAssertEqual(viewModel.appLanguage, .en)
        XCTAssertEqual(store.appLanguage, .en)
        XCTAssertEqual(AppStrings.currentLanguage, .en)

        viewModel.setAppLanguage(.zhHant)
        XCTAssertEqual(viewModel.appLanguage, .zhHant)
        XCTAssertEqual(store.appLanguage, .zhHant)
        XCTAssertEqual(AppStrings.currentLanguage, .zhHant)
    }

    @MainActor
    func testMenubarIconRendererGeneratesImage() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 2))!

        let zhImage = MenubarIconRenderer.createStackedIcon(
            date: date,
            calendar: Calendar.current,
            language: .zhHant
        )
        XCTAssertTrue(zhImage.isTemplate)
        XCTAssertGreaterThan(zhImage.size.width, 0)
        XCTAssertEqual(zhImage.size.height, 22)

        let enImage = MenubarIconRenderer.createStackedIcon(
            date: date,
            calendar: Calendar.current,
            language: .en
        )
        XCTAssertTrue(enImage.isTemplate)
        XCTAssertGreaterThan(enImage.size.width, 0)
        XCTAssertEqual(enImage.size.height, 22)
    }
}

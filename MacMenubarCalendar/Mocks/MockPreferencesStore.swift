import Foundation

@MainActor
public final class MockPreferencesStore: PreferencesStoreProtocol {
    public var selectedCalendarIds: Set<String>?
    public var showDeclinedEvents: Bool
    public var appearanceMode: AppearanceMode
    public var appLanguage: AppLanguage
    public var launchAtLogin: Bool
    public var windowWidth: Double
    public var windowHeight: Double
    public var isPinned: Bool

    public init(
        selectedCalendarIds: Set<String>? = nil,
        showDeclinedEvents: Bool = false,
        appearanceMode: AppearanceMode = .system,
        appLanguage: AppLanguage = .system,
        launchAtLogin: Bool = false,
        windowWidth: Double = 680,
        windowHeight: Double = 460,
        isPinned: Bool = false
    ) {
        self.selectedCalendarIds = selectedCalendarIds
        self.showDeclinedEvents = showDeclinedEvents
        self.appearanceMode = appearanceMode
        self.appLanguage = appLanguage
        self.launchAtLogin = launchAtLogin
        self.windowWidth = windowWidth
        self.windowHeight = windowHeight
        self.isPinned = isPinned
    }

    public func registerDefaults() {
        // Defaults registered
    }
}
